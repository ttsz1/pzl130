import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/orlik_game.dart';
import '../game/score_service.dart';

class OrlikGameScreen extends StatefulWidget {
  final String userId;
  const OrlikGameScreen({super.key, required this.userId});

  @override
  State<OrlikGameScreen> createState() => _OrlikGameScreenState();
}

class _OrlikGameScreenState extends State<OrlikGameScreen> {
  late OrlikGame _game;
  final _scoreService = ScoreService();

  @override
  void initState() {
    super.initState();
    _game = OrlikGame();
  }

  Future<void> _saveScore() async {
    final best = await _scoreService.getHighScore(widget.userId);
    if (_game.score > best) {
      await _scoreService.updateHighScore(widget.userId, _game.score);
    }
  }

  void _restartGame() {
    setState(() {
      _game = OrlikGame();
    });
  }

  @override
  void dispose() {
    _saveScore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(game: _game),

          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Wyjdź"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _restartGame,
                  child: const Text("Restart"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
