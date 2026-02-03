class Match3Level {
  final int rows;
  final int cols;
  final int targetCount; // ile śmigieł trzeba zebrać
  final int moves;       // ile ruchów
  final int elementTypes;

  const Match3Level({
    required this.rows,
    required this.cols,
    required this.targetCount,
    required this.moves,
    required this.elementTypes,
  });
}

const match3Levels = [
  Match3Level(rows: 8, cols: 8, targetCount: 10, moves: 18, elementTypes: 5),
  Match3Level(rows: 8, cols: 8, targetCount: 18, moves: 30, elementTypes: 6),
  Match3Level(rows: 8, cols: 8, targetCount: 28, moves: 45, elementTypes: 6),
];
