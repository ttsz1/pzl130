import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'bullet.dart';
import 'orlik_game.dart';
import 'orlik_player.dart';

class ShahedDrone extends SpriteComponent
    with CollisionCallbacks, HasGameRef<OrlikGame> {
  ShahedDrone({required Vector2 position})
      : super(position: position, size: Vector2(80, 80));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('shahed.png');
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    y += 140 * dt;

    if (y > gameRef.size.y + 50) {
      gameRef.loseLife();
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is Bullet) {
      gameRef.addScore();
      other.removeFromParent();
      removeFromParent();
    }

    if (other is OrlikPlayer) {
      gameRef.loseLife();
      removeFromParent();
    }
  }
}
