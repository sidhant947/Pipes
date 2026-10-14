import 'package:flutter/foundation.dart';
import 'package:pipes/domain/models/user_progress.dart';
import '../services/hive_service.dart';

class ProgressRepository extends ChangeNotifier {
  ProgressRepository({required this.hiveService});

  final HiveService hiveService;
  UserProgress? _cachedProgress;

  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    _cachedProgress = await hiveService.getProgress();
    return _cachedProgress!;
  }

  Future<void> saveProgress(UserProgress progress) async {
    _cachedProgress = progress;
    await hiveService.saveProgress(progress);
    notifyListeners();
  }

  Future<void> completeLevel(int levelNumber, int moves) async {
    final current = await getProgress();
    final isNewCompletion = levelNumber == current.highestLevelCompleted + 1;
    final updated = isNewCompletion
        ? current.incrementLevel().addMoves(moves)
        : current.addMoves(moves);
    await saveProgress(updated);
  }

  Future<void> addRandomLevelMoves(int moves) async {
    final current = await getProgress();
    final updated = current.addMoves(moves);
    await saveProgress(updated);
  }

  Future<void> recordLevelResult(int level, int moves, int seconds) async {
    final current = await getProgress();
    await saveProgress(current.recordLevelResult(level, moves, seconds));
  }

  Future<void> saveInProgress(
    int level,
    List<List<int>> board,
    int moves,
    int seconds,
  ) async {
    final current = await getProgress();
    await saveProgress(
      current.withSavedGame(
        levelNumber: level,
        board: board,
        moveCount: moves,
        elapsedSeconds: seconds,
      ),
    );
  }

  Future<void> clearInProgress() async {
    final current = await getProgress();
    if (current.savedLevelNumber == null) return;
    await saveProgress(current.withoutSavedGame());
  }

  Future<void> resetProgress() async {
    _cachedProgress = null;
    await hiveService.clearProgress();
    notifyListeners();
  }
}
