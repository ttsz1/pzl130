import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'orlik_game.dart';

class GameOverOverlay extends StatefulWidget {
  final OrlikGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  List<Map<String, dynamic>> topScores = [];

  @override
  void initState() {
    super.initState();
    loadTopScores();
  }

  Future<void> loadTopScores() async {
    final supabase = Supabase.instance.client;

    // 🔥 Pobieramy highscore + imię użytkownika
    final data = await supabase
        .from('scores')
        .select('highscore, profiles(first_name)')
        .order('highscore', ascending: false)
        .limit(10);

    setState(() {
      topScores = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "GAME OVER",
              style: TextStyle(
                fontSize: 36,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Score: ${game.score}",
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
            Text(
              "High Score: ${game.highScore}",
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),

            const SizedBox(height: 20),
            const Text(
              "TOP 10",
              style: TextStyle(fontSize: 20, color: Colors.yellow),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 200,
              child: topScores.isEmpty
                  ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : ListView.builder(
                itemCount: topScores.length,
                itemBuilder: (context, i) {
                  final row = topScores[i];

                  final name =
                      row['profiles']?['first_name'] ?? "Unknown";
                  final score = row['highscore'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      "${i + 1}.  $name — $score",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                game.overlays.remove('gameOver');
                game.resumeEngine();
                game.resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 45),
              ),
              child: const Text("TRY AGAIN"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(200, 45),
              ),
              child: const Text("QUIT"),
            ),
          ],
        ),
      ),
    );
  }
}
