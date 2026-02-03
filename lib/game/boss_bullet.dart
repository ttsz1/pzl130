import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'orlik_game.dart';
import 'orlik_player.dart';

class BossBullet extends SpriteComponent
    with CollisionCallbacks, HasGameRef<OrlikGame> {
  final double angle;

  BossBullet({required Vector2 position, required this.angle})
      : super(position: position, size: Vector2(20, 40));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    x += 200 * dt * angle;
    y += 300 * dt;

    if (y > gameRef.size.y + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is OrlikPlayer) {
      gameRef.loseLife();
      removeFromParent();
    }
  }
}
