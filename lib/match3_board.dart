import 'dart:math';

class PointRC {
  final int row;
  final int col;
  const PointRC(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is PointRC && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}

class Match3Board {
  final int rows;
  final int cols;
  final int types;
  final Random _rand = Random();

  late List<List<int>> grid;

  Match3Board({
    required this.rows,
    required this.cols,
    required this.types,
  }) {
    _generateValidBoard();
  }

  void _generateValidBoard() {
    do {
      grid = List.generate(
        rows,
            (_) => List.generate(cols, (_) => _rand.nextInt(types)),
      );
      _clearInitialMatches();
    } while (!hasAnyPossibleMove());
  }

  void _clearInitialMatches() {
    while (true) {
      final matches = _findMatches();
      if (matches.isEmpty) break;
      for (final p in matches) {
        grid[p.row][p.col] = _rand.nextInt(types);
      }
    }
  }

  bool isInside(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  PointRC _p(int r, int c) => PointRC(r, c);

  Set<PointRC> _findMatches() {
    final matches = <PointRC>{};

    // poziome
    for (int r = 0; r < rows; r++) {
      int count = 1;
      for (int c = 1; c < cols; c++) {
        if (grid[r][c] == grid[r][c - 1]) {
          count++;
        } else {
          if (count >= 3) {
            for (int k = 0; k < count; k++) {
              matches.add(_p(r, c - 1 - k));
            }
          }
          count = 1;
        }
      }
      if (count >= 3) {
        for (int k = 0; k < count; k++) {
          matches.add(_p(r, cols - 1 - k));
        }
      }
    }

    // pionowe
    for (int c = 0; c < cols; c++) {
      int count = 1;
      for (int r = 1; r < rows; r++) {
        if (grid[r][c] == grid[r - 1][c]) {
          count++;
        } else {
          if (count >= 3) {
            for (int k = 0; k < count; k++) {
              matches.add(_p(r - 1 - k, c));
            }
          }
          count = 1;
        }
      }
      if (count >= 3) {
        for (int k = 0; k < count; k++) {
          matches.add(_p(rows - 1 - k, c));
        }
      }
    }

    return matches;
  }

  bool isValidSwap(int r1, int c1, int r2, int c2) {
    if (!isInside(r1, c1) || !isInside(r2, c2)) return false;
    if (!((r1 == r2 && (c1 - c2).abs() == 1) ||
        (c1 == c2 && (r1 - r2).abs() == 1))) {
      return false;
    }

    _swap(r1, c1, r2, c2);
    final hasMatch = _findMatches().isNotEmpty;
    _swap(r1, c1, r2, c2);
    return hasMatch;
  }

  void _swap(int r1, int c1, int r2, int c2) {
    final tmp = grid[r1][c1];
    grid[r1][c1] = grid[r2][c2];
    grid[r2][c2] = tmp;
  }

  int performMove(int r1, int c1, int r2, int c2) {
    if (!isValidSwap(r1, c1, r2, c2)) return 0;

    _swap(r1, c1, r2, c2);

    int totalRemoved = 0;

    while (true) {
      final matches = _findMatches();
      if (matches.isEmpty) break;

      totalRemoved += matches.length;

      for (final p in matches) {
        grid[p.row][p.col] = -1;
      }

      // grawitacja + refill
      for (int c = 0; c < cols; c++) {
        int writeRow = rows - 1;
        for (int r = rows - 1; r >= 0; r--) {
          if (grid[r][c] != -1) {
            grid[writeRow][c] = grid[r][c];
            writeRow--;
          }
        }
        for (int r = writeRow; r >= 0; r--) {
          grid[r][c] = _rand.nextInt(types);
        }
      }
    }

    return totalRemoved;
  }

  bool hasAnyPossibleMove() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (isValidSwap(r, c, r, c + 1)) return true;
        if (isValidSwap(r, c, r + 1, c)) return true;
      }
    }
    return false;
  }
}
