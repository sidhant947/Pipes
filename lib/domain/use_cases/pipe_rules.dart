import 'dart:collection';
import 'package:pipes/domain/models/game_level.dart';

class PipeRules {
  const PipeRules._();

  static int rotateCw(int mask) {
    return ((mask << 1) & 0xF) | ((mask >> 3) & 0x1);
  }

  static int rotateCcw(int mask) {
    return ((mask >> 1) & 0x7) | ((mask << 3) & 0x8);
  }

  static List<List<bool>> computeWaterFlow(
    List<List<int>> board,
    int sourceR,
    int sourceC,
  ) {
    final n = board.length;
    final flow = List.generate(n, (_) => List<bool>.filled(n, false));
    if (sourceR < 0 || sourceR >= n || sourceC < 0 || sourceC >= n) {
      return flow;
    }

    final queue = Queue<List<int>>();
    flow[sourceR][sourceC] = true;
    queue.add([sourceR, sourceC]);

    while (queue.isNotEmpty) {
      final curr = queue.removeFirst();
      final r = curr[0];
      final c = curr[1];
      final mask = board[r][c];

      if ((mask & 1) != 0 && r > 0 && (board[r - 1][c] & 4) != 0 && !flow[r - 1][c]) {
        flow[r - 1][c] = true;
        queue.add([r - 1, c]);
      }
      if ((mask & 2) != 0 && c < n - 1 && (board[r][c + 1] & 8) != 0 && !flow[r][c + 1]) {
        flow[r][c + 1] = true;
        queue.add([r, c + 1]);
      }
      if ((mask & 4) != 0 && r < n - 1 && (board[r + 1][c] & 1) != 0 && !flow[r + 1][c]) {
        flow[r + 1][c] = true;
        queue.add([r + 1, c]);
      }
      if ((mask & 8) != 0 && c > 0 && (board[r][c - 1] & 2) != 0 && !flow[r][c - 1]) {
        flow[r][c - 1] = true;
        queue.add([r, c - 1]);
      }
    }

    return flow;
  }

  static bool isComplete(List<List<int>> board, GameLevel level) {
    final n = level.gridSize;
    if (board.length != n) return false;

    final flow = computeWaterFlow(board, level.sourceRow, level.sourceCol);

    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (!flow[r][c]) return false;
        final mask = board[r][c];
        if ((mask & 1) != 0 && (r == 0 || (board[r - 1][c] & 4) == 0)) return false;
        if ((mask & 2) != 0 && (c == n - 1 || (board[r][c + 1] & 8) == 0)) return false;
        if ((mask & 4) != 0 && (r == n - 1 || (board[r + 1][c] & 1) == 0)) return false;
        if ((mask & 8) != 0 && (c == 0 || (board[r][c - 1] & 2) == 0)) return false;
      }
    }

    return true;
  }

  static int countWaterPipes(List<List<bool>> flow) {
    int count = 0;
    for (final row in flow) {
      for (final cell in row) {
        if (cell) count++;
      }
    }
    return count;
  }

  static List<int>? suggestHint(List<List<int>> board, GameLevel level) {
    final n = level.gridSize;
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] != level.solutionMasks[r][c]) {
          return [r, c];
        }
      }
    }
    return null;
  }
}
