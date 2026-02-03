import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'bullet.dart';
import 'orlik_game.dart';
import 'powerup.dart';

class OrlikPlayer extends SpriteComponent
    with CollisionCallbacks, HasGameRef<OrlikGame> {
  OrlikPlayer() : super(size: Vector2(90, 90));

  double targetX = 0;
  double fireRate = 0.9;
  bool extraBullet = false;

  late Timer autoFire;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('orlik.png');
    anchor = Anchor.center;
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 140);

    add(RectangleHitbox());

    targetX = x;

    autoFire = Timer(fireRate, repeat: true, onTick: shoot);
  }

  @override
  void update(double dt) {
    super.update(dt);
    autoFire.update(dt);

    // płynne podążanie za palcem
    final dx = targetX - x;
    x += dx * 8 * dt;

    // ograniczenie ruchu
    final half = width / 2;
    if (x < half) x = half;
    if (x > gameRef.size.x - half) x = gameRef.size.x - half;
  }

  void moveTo(double xPos) {
    targetX = xPos;
  }

  void shoot() {
    gameRef.add(Bullet(position: position.clone(), angle: 0));

    if (extraBullet) {
      gameRef.add(Bullet(position: position.clone(), angle: 0.52));
      gameRef.add(Bullet(position: position.clone(), angle: -0.52));
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is PowerUp) {
      switch (other.type) {
        case PowerUpType.extraBullet:
          extraBullet = true;
          break;

        case PowerUpType.fastFire:
          fireRate = fireRate - 0.1;
          autoFire.stop();
          autoFire = Timer(fireRate, repeat: true, onTick: shoot);
          break;

        case PowerUpType.extraLife:
          gameRef.addLife();
          break;
      }

      other.removeFromParent();
    }
  }
}
