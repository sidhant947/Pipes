import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/data/repositories/progress_repository.dart';
import 'package:pipes/data/services/settings_service.dart';
import 'package:pipes/domain/models/game_level.dart';
import 'package:pipes/domain/use_cases/level_generator.dart';
import 'package:pipes/domain/use_cases/pipe_rules.dart';

@immutable
class GameViewModelState {
  const GameViewModelState({
    this.level,
    this.board = const [],
    this.waterFlow = const [],
    this.isLoading = false,
    this.isComplete = false,
    this.moveCount = 0,
    this.elapsedSeconds = 0,
    this.hintCell,
    this.hintsRemaining = 3,
    this.error,
    this.isRandomMode = false,
    this.randomDifficulty,
    this.randomSeed,
    this.randomGridSize,
  });

  final GameLevel? level;
  final List<List<int>> board;
  final List<List<bool>> waterFlow;
  final bool isLoading;
  final bool isComplete;
  final int moveCount;
  final int elapsedSeconds;
  final int? hintCell;
  final int hintsRemaining;
  final String? error;
  final bool isRandomMode;
  final String? randomDifficulty;
  final int? randomSeed;
  final int? randomGridSize;

  int get connectedCount => PipeRules.countWaterPipes(waterFlow);

  GameViewModelState copyWith({
    GameLevel? level,
    List<List<int>>? board,
    List<List<bool>>? waterFlow,
    bool? isLoading,
    bool? isComplete,
    int? moveCount,
    int? elapsedSeconds,
    int? hintCell,
    bool clearHint = false,
    int? hintsRemaining,
    String? error,
    bool? isRandomMode,
    String? randomDifficulty,
    int? randomSeed,
    int? randomGridSize,
  }) {
    return GameViewModelState(
      level: level ?? this.level,
      board: board ?? this.board,
      waterFlow: waterFlow ?? this.waterFlow,
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      moveCount: moveCount ?? this.moveCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hintCell: clearHint ? null : (hintCell ?? this.hintCell),
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      error: error,
      isRandomMode: isRandomMode ?? this.isRandomMode,
      randomDifficulty: randomDifficulty ?? this.randomDifficulty,
      randomSeed: randomSeed ?? this.randomSeed,
      randomGridSize: randomGridSize ?? this.randomGridSize,
    );
  }
}

class GameViewModel extends StateNotifier<GameViewModelState> {
  GameViewModel({
    required this.progressRepository,
    required this.levelGenerator,
    required this.settingsService,
  }) : super(const GameViewModelState());

  final ProgressRepository progressRepository;
  final LevelGenerator levelGenerator;
  final SettingsService settingsService;

  Timer? _timer;
  Timer? _hintTimer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _stopTimer();
        return;
      }
      if (state.isComplete) {
        _timer?.cancel();
        return;
      }
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> loadLevel(int levelNumber) async {
    state = const GameViewModelState(isLoading: true);

    try {
      final level = await levelGenerator.generateAsync(levelNumber);
      if (!mounted) return;

      final progress = await progressRepository.getProgress();
      if (!mounted) return;

      List<List<int>> board;
      int moveCount = 0;
      int elapsed = 0;

      if (progress.savedLevelNumber == levelNumber &&
          progress.savedBoard != null &&
          progress.savedBoard!.length == level.gridSize) {
        board = progress.savedBoard!
            .map((row) => List<int>.from(row))
            .toList();
        moveCount = progress.savedMoveCount;
        elapsed = progress.savedElapsedSeconds;
      } else {
        board = level.initialMasks
            .map((row) => List<int>.from(row))
            .toList();
      }

      final flow = PipeRules.computeWaterFlow(board, level.sourceRow, level.sourceCol);
      final isComplete = PipeRules.isComplete(board, level);

      state = GameViewModelState(
        level: level,
        board: board,
        waterFlow: flow,
        moveCount: moveCount,
        elapsedSeconds: elapsed,
        isComplete: isComplete,
        hintsRemaining: 3,
      );

      if (!isComplete) _startTimer();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load level: $e',
      );
    }
  }

  int _parseGridSize(String difficulty) {
    final lower = difficulty.toLowerCase().trim();
    if (lower.contains('x')) {
      final parts = lower.split('x');
      final size = int.tryParse(parts[0].trim());
      if (size != null && size >= 4 && size <= 12) return size;
    }
    switch (lower) {
      case 'easy':
      case '4x4':
        return 4;
      case '5x5':
        return 5;
      case 'medium':
      case '6x6':
        return 6;
      case '7x7':
        return 7;
      case 'hard':
      case '8x8':
        return 8;
      case '9x9':
        return 9;
      case 'expert':
      case '10x10':
        return 10;
      case '11x11':
        return 11;
      case 'master':
      case '12x12':
        return 12;
      default:
        final parsed = int.tryParse(difficulty);
        if (parsed != null && parsed >= 4 && parsed <= 12) return parsed;
        return 4;
    }
  }

  Future<void> loadRandomLevel(String difficulty, {int? seed}) async {
    final int levelSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final int gridSize = _parseGridSize(difficulty);

    state = GameViewModelState(
      isLoading: true,
      isRandomMode: true,
      randomDifficulty: difficulty,
      randomSeed: levelSeed,
      randomGridSize: gridSize,
      hintsRemaining: 3,
    );

    try {
      final level = await levelGenerator.generateRandomAsync(
        gridSize: gridSize,
        seed: levelSeed,
      );
      if (!mounted) return;

      final board = level.initialMasks
          .map((row) => List<int>.from(row))
          .toList();

      final flow = PipeRules.computeWaterFlow(board, level.sourceRow, level.sourceCol);
      final isComplete = PipeRules.isComplete(board, level);

      state = state.copyWith(
        level: level,
        board: board,
        waterFlow: flow,
        moveCount: 0,
        elapsedSeconds: 0,
        isLoading: false,
        isComplete: isComplete,
        randomGridSize: gridSize,
        hintsRemaining: 3,
      );

      if (!isComplete) _startTimer();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load random level: $e',
      );
    }
  }

  void rotateTile(int r, int c) {
    final level = state.level;
    if (state.isComplete || level == null) return;
    if (r < 0 || r >= level.gridSize || c < 0 || c >= level.gridSize) return;

    final n = level.gridSize;
    final newBoard = List.generate(
      n,
      (row) => List<int>.from(state.board[row]),
    );

    newBoard[r][c] = PipeRules.rotateCw(newBoard[r][c]);

    final flow = PipeRules.computeWaterFlow(newBoard, level.sourceRow, level.sourceCol);
    final isComplete = PipeRules.isComplete(newBoard, level);

    final oldWaterCount = state.connectedCount;
    final newWaterCount = PipeRules.countWaterPipes(flow);

    if (isComplete) {
      HapticFeedback.heavyImpact();
      _stopTimer();
    } else if (newWaterCount > oldWaterCount) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    state = state.copyWith(
      board: newBoard,
      waterFlow: flow,
      moveCount: state.moveCount + 1,
      isComplete: isComplete,
      clearHint: true,
    );

    _persistInProgress();
  }

  void revealHint() {
    final level = state.level;
    if (level == null || state.isComplete) return;

    final hintPos = PipeRules.suggestHint(state.board, level);
    if (hintPos == null) return;

    final targetRow = hintPos[0];
    final targetCol = hintPos[1];

    final newBoard = state.board
        .map((row) => List<int>.from(row))
        .toList();
    newBoard[targetRow][targetCol] = level.solutionMasks[targetRow][targetCol];

    final flow = PipeRules.computeWaterFlow(newBoard, level.sourceRow, level.sourceCol);
    final isComplete = PipeRules.isComplete(newBoard, level);

    if (isComplete) {
      HapticFeedback.heavyImpact();
      _stopTimer();
    } else {
      HapticFeedback.mediumImpact();
    }

    final encoded = targetRow * level.gridSize + targetCol;

    state = state.copyWith(
      board: newBoard,
      waterFlow: flow,
      moveCount: state.moveCount + 1,
      isComplete: isComplete,
      hintCell: encoded,
    );

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) state = state.copyWith(clearHint: true);
    });

    _persistInProgress();
  }

  void _persistInProgress() {
    final level = state.level;
    if (level == null || state.isRandomMode) return;
    if (state.isComplete) return;
    progressRepository.saveInProgress(
      level.levelNumber,
      state.board,
      state.moveCount,
      state.elapsedSeconds,
    );
  }

  Future<void> completeLevel() async {
    final level = state.level;
    if (level == null || !state.isComplete) return;
    if (state.isRandomMode) {
      await progressRepository.addRandomLevelMoves(state.moveCount);
    } else {
      await progressRepository.completeLevel(level.levelNumber, state.moveCount);
      if (!mounted) return;
      await progressRepository.recordLevelResult(
        level.levelNumber,
        state.moveCount,
        state.elapsedSeconds,
      );
      if (!mounted) return;
      await progressRepository.clearInProgress();
    }
  }

  Future<void> resetLevel() async {
    final level = state.level;
    if (level == null) return;
    if (state.isRandomMode) {
      await loadRandomLevel(
        state.randomDifficulty ?? 'Easy',
        seed: state.randomSeed,
      );
    } else {
      await progressRepository.clearInProgress();
      if (!mounted) return;
      await loadLevel(level.levelNumber);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _hintTimer?.cancel();
    super.dispose();
  }
}
