import 'package:flame/components.dart';

class Hud extends PositionComponent {
  late TextComponent scoreText;
  late TextComponent livesText;

  @override
  Future<void> onLoad() async {
    scoreText = TextComponent(
      text: "Wynik: 0",
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
    );

    livesText = TextComponent(
      text: "Życia: 3",
      position: Vector2(10, 40),
      anchor: Anchor.topLeft,
    );

    add(scoreText);
    add(livesText);
  }

  void updateScore(int score) {
    scoreText.text = "Wynik: $score";
  }

  void updateLives(int lives) {
    livesText.text = "Życia: $lives";
  }
}
