import 'dart:math';
import 'package:flutter/material.dart';
import 'match3_board.dart';
import 'match3_level.dart';

class Match3Screen extends StatefulWidget {
  final int levelIndex;

  const Match3Screen({super.key, this.levelIndex = 0});

  @override
  State<Match3Screen> createState() => _Match3ScreenState();
}

class _Match3ScreenState extends State<Match3Screen> {
  late Match3Level level;
  late Match3Board board;

  int movesLeft = 0;
  int collectedTarget = 0;
  Point<int>? selected;

  static const int targetType = 0; // typ 0 = „śmigło”

  @override
  void initState() {
    super.initState();
    level = match3Levels[widget.levelIndex];
    board = Match3Board(
      rows: level.rows,
      cols: level.cols,
      types: level.elementTypes,
    );
    movesLeft = level.moves;
  }

  void _onTileTap(int r, int c) {
    setState(() {
      if (selected == null) {
        selected = Point(r, c);
      } else {
        final sr = selected!.x;
        final sc = selected!.y;

        final isNeighbor =
            (sr == r && (sc - c).abs() == 1) ||
                (sc == c && (sr - r).abs() == 1);

        if (isNeighbor) {
          // policzymy ile targetów zniknęło
          final before = _countTargetOnBoard();
          final removed = board.performMove(sr, sc, r, c);
          final after = _countTargetOnBoard();

          if (removed > 0) {
            movesLeft--;

            final diff = (before - after).clamp(0, removed);
            collectedTarget += diff;

            _checkWinLose();
          }

          selected = null;
        } else {
          selected = Point(r, c);
        }
      }
    });
  }

  int _countTargetOnBoard() {
    int count = 0;
    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        if (board.grid[r][c] == targetType) count++;
      }
    }
    return count;
  }

  void _checkWinLose() {
    if (collectedTarget >= level.targetCount) {
      _showEndDialog("MISJA WYKONANA", success: true);
    } else if (movesLeft <= 0) {
      _showEndDialog("MISJA NIEUDANA", success: false);
    }
  }

  void _showEndDialog(String title, {required bool success}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          title,
          style: TextStyle(
            color: success ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Zebrane śmigła: $collectedTarget / ${level.targetCount}\n"
              "Pozostałe ruchy: $movesLeft",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "WYJDŹ",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          if (success && widget.levelIndex + 1 < match3Levels.length)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        Match3Screen(levelIndex: widget.levelIndex + 1),
                  ),
                );
              },
              child: const Text(
                "NASTĘPNY POZIOM",
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cellSize = 36.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ZBIERZ 3 — MISJA ŚMIGŁA"),
        backgroundColor: Colors.green.shade900,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            "Cel: zbierz ${level.targetCount} śmigieł",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            "Zebrane: $collectedTarget",
            style:
            const TextStyle(color: Colors.lightGreenAccent, fontSize: 16),
          ),
          Text(
            "Ruchy: $movesLeft",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: SizedBox(
                width: level.cols * cellSize,
                height: level.rows * cellSize,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: level.cols,
                  ),
                  itemCount: level.rows * level.cols,
                  itemBuilder: (context, index) {
                    final r = index ~/ level.cols;
                    final c = index % level.cols;
                    final value = board.grid[r][c];

                    final isSelected =
                        selected?.x == r && selected?.y == c;

                    Color color;
                    IconData icon;

                    switch (value) {
                      case 0:
                        color = Colors.lightBlueAccent;
                        icon = Icons.air; // śmigło
                        break;
                      case 1:
                        color = Colors.orangeAccent;
                        icon = Icons.local_fire_department;
                        break;
                      case 2:
                        color = Colors.purpleAccent;
                        icon = Icons.bolt;
                        break;
                      case 3:
                        color = Colors.greenAccent;
                        icon = Icons.shield;
                        break;
                      default:
                        color = Colors.redAccent;
                        icon = Icons.bug_report;
                    }

                    return GestureDetector(
                      onTap: () => _onTileTap(r, c),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white24
                              : Colors.grey.shade900,
                          border: Border.all(color: Colors.green.shade800),
                        ),
                        child: Center(
                          child: Icon(icon, color: color, size: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
