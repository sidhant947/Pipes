import 'package:flutter/material.dart';

@immutable
class GameLevel {
  const GameLevel({
    required this.levelNumber,
    required this.gridSize,
    required this.sourceRow,
    required this.sourceCol,
    required this.solutionMasks,
    required this.initialMasks,
  });

  final int levelNumber;
  final int gridSize;
  final int sourceRow;
  final int sourceCol;
  final List<List<int>> solutionMasks;
  final List<List<int>> initialMasks;

  int get totalPipes => gridSize * gridSize;

  GameLevel copyWith({
    int? levelNumber,
    int? gridSize,
    int? sourceRow,
    int? sourceCol,
    List<List<int>>? solutionMasks,
    List<List<int>>? initialMasks,
  }) {
    return GameLevel(
      levelNumber: levelNumber ?? this.levelNumber,
      gridSize: gridSize ?? this.gridSize,
      sourceRow: sourceRow ?? this.sourceRow,
      sourceCol: sourceCol ?? this.sourceCol,
      solutionMasks: solutionMasks ?? this.solutionMasks,
      initialMasks: initialMasks ?? this.initialMasks,
    );
  }
}
