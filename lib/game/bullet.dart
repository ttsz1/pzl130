import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'orlik_game.dart';

class Bullet extends SpriteComponent
    with CollisionCallbacks, HasGameRef<OrlikGame> {
  final double angle;

  Bullet({required Vector2 position, required this.angle})
      : super(position: position, size: Vector2(12, 28));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bullet.png');
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    x += 300 * dt * angle;
    y -= 400 * dt;

    if (y < -20) removeFromParent();
  }
}
