import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'orlik_game.dart';

enum PowerUpType {
  extraBullet,
  fastFire,
  extraLife,
}

class PowerUp extends SpriteComponent
    with CollisionCallbacks, HasGameRef<OrlikGame> {
  final PowerUpType type;

  PowerUp({required this.type, required Vector2 position})
      : super(position: position, size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    String asset = switch (type) {
      PowerUpType.extraBullet => 'power_extra_bullet.png',
      PowerUpType.fastFire => 'power_fast_fire.png',
      PowerUpType.extraLife => 'power_life.png',
    };

    sprite = await gameRef.loadSprite(asset);
    anchor = Anchor.center;

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    y += 100 * dt;

    if (y > gameRef.size.y + 50) {
      removeFromParent();
    }
  }
}
