import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pipes/domain/models/game_level.dart';
import 'package:pipes/domain/use_cases/pipe_rules.dart';

class LevelGenerator {
  final Map<int, GameLevel> _cache = {};
  final Set<int> _generating = {};

  GameLevel generate(int levelNumber) {
    GameLevel level;
    if (_cache.containsKey(levelNumber)) {
      level = _cache.remove(levelNumber)!;
    } else {
      level = _generateInternal(levelNumber);
    }
    _generating.remove(levelNumber);
    _pregenerateNext(levelNumber + 1);
    return level;
  }

  Future<GameLevel> generateAsync(int levelNumber) async {
    GameLevel level;
    if (_cache.containsKey(levelNumber)) {
      level = _cache.remove(levelNumber)!;
    } else {
      level = await compute(_isolateGenerate, levelNumber);
    }
    _generating.remove(levelNumber);
    _pregenerateNext(levelNumber + 1);
    return level;
  }

  GameLevel _generateInternal(int levelNumber) {
    final random = Random(levelNumber * 7919 + 17);
    final gridSize = _getGridSize(levelNumber);
    return _generateLevelWithSeed(levelNumber, gridSize, random);
  }

  void pregenerateAround(int currentLevel, {int range = 1}) {
    for (int i = 0; i <= range; i++) {
      final levelNumber = currentLevel + i;
      if (levelNumber < 1) continue;
      if (!_cache.containsKey(levelNumber) && !_generating.contains(levelNumber)) {
        _generating.add(levelNumber);
        compute(_isolateGenerate, levelNumber).then((level) {
          _cache[levelNumber] = level;
          _generating.remove(levelNumber);
        }).catchError((e) {
          _generating.remove(levelNumber);
        });
      }
    }
  }

  void _pregenerateNext(int startLevel) {
    pregenerateAround(startLevel, range: 1);
  }

  static GameLevel _isolateGenerate(int levelNumber) {
    return LevelGenerator()._generateInternal(levelNumber);
  }

  static GameLevel _isolateGenerateRandom(Map<String, int> params) {
    return LevelGenerator().generateRandom(
      gridSize: params['gridSize']!,
      seed: params['seed']!,
    );
  }

  Future<GameLevel> generateRandomAsync({required int gridSize, required int seed}) {
    return compute(_isolateGenerateRandom, {'gridSize': gridSize, 'seed': seed});
  }

  GameLevel generateRandom({required int gridSize, required int seed}) {
    final random = Random(seed);
    return _generateLevelWithSeed(-1, gridSize, random);
  }

  int _getGridSize(int level) {
    if (level <= 3) return 4;
    if (level <= 10) return 5;
    if (level <= 25) return 6;
    if (level <= 50) return 7;
    if (level <= 85) return 8;
    if (level <= 130) return 9;
    if (level <= 185) return 10;
    if (level <= 250) return 11;
    return 12;
  }

  GameLevel _generateLevelWithSeed(
    int levelNumber,
    int gridSize,
    Random random,
  ) {
    final sourceRow = gridSize ~/ 2;
    final sourceCol = gridSize ~/ 2;

    final solutionMasks = List.generate(
      gridSize,
      (_) => List<int>.filled(gridSize, 0),
    );
    final visited = List.generate(
      gridSize,
      (_) => List<bool>.filled(gridSize, false),
    );

    visited[sourceRow][sourceCol] = true;
    final stack = <Point<int>>[Point(sourceRow, sourceCol)];

    while (stack.isNotEmpty) {
      final current = stack.last;
      final r = current.x;
      final c = current.y;

      final neighbors = <List<int>>[];
      if (r > 0 && !visited[r - 1][c]) {
        neighbors.add([r - 1, c, 1, 4]);
      }
      if (c < gridSize - 1 && !visited[r][c + 1]) {
        neighbors.add([r, c + 1, 2, 8]);
      }
      if (r < gridSize - 1 && !visited[r + 1][c]) {
        neighbors.add([r + 1, c, 4, 1]);
      }
      if (c > 0 && !visited[r][c - 1]) {
        neighbors.add([r, c - 1, 8, 2]);
      }

      if (neighbors.isEmpty) {
        stack.removeLast();
      } else {
        final chosen = neighbors[random.nextInt(neighbors.length)];
        final nr = chosen[0];
        final nc = chosen[1];
        final dir = chosen[2];
        final opp = chosen[3];

        solutionMasks[r][c] |= dir;
        solutionMasks[nr][nc] |= opp;
        visited[nr][nc] = true;
        stack.add(Point(nr, nc));
      }
    }

    final initialMasks = List.generate(
      gridSize,
      (r) => List<int>.filled(gridSize, 0),
    );

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final solved = solutionMasks[r][c];
        if (solved == 15) {
          initialMasks[r][c] = solved;
        } else if (solved == 5 || solved == 10) {
          initialMasks[r][c] = PipeRules.rotateCw(solved);
        } else {
          final turns = 1 + random.nextInt(3);
          int scrambled = solved;
          for (int k = 0; k < turns; k++) {
            scrambled = PipeRules.rotateCw(scrambled);
          }
          initialMasks[r][c] = scrambled;
        }
      }
    }

    return GameLevel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      sourceRow: sourceRow,
      sourceCol: sourceCol,
      solutionMasks: solutionMasks,
      initialMasks: initialMasks,
    );
  }
}
