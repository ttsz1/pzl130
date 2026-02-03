import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'bullet.dart';
import 'orlik_game.dart';
import 'orlik_player.dart';
import 'boss_bullet.dart';

class BossBryza extends SpriteComponent
    with CollisionCallbacks, HasGameRef<OrlikGame> {
  int hp = 20;

  late RectangleComponent hpBarBg;
  late RectangleComponent hpBar;

  BossBryza({required Vector2 position})
      : super(position: position, size: Vector2(220, 220));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('bryza.png');
    anchor = Anchor.center;

    add(RectangleHitbox());

    // TŁO paska HP
    hpBarBg = RectangleComponent(
      size: Vector2(200, 12),
      anchor: Anchor.center,
      position: Vector2(0, -150),
      paint: Paint()..color = const Color(0xFF222222),
    );

    // Właściwy pasek HP
    hpBar = RectangleComponent(
      size: Vector2(200, 12),
      anchor: Anchor.centerLeft,
      position: Vector2(-100, -150),
      paint: Paint()..color = const Color(0xFFFF0000),
    );

    add(hpBarBg);
    add(hpBar);

    // Strzelanie bossa co 1.5 sekundy
    add(
      TimerComponent(
        period: 1.5,
        repeat: true,
        onTick: shoot,
      ),
    );
  }

  void shoot() {
    // trzy pociski w dół
    gameRef.add(BossBullet(position: position.clone(), angle: 0));
    gameRef.add(BossBullet(position: position.clone(), angle: 0.4));
    gameRef.add(BossBullet(position: position.clone(), angle: -0.4));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // boss opada tylko do 150 px od góry
    const double targetY = 150;

    if (y < targetY) {
      y += 40 * dt;
    } else {
      y = targetY;
    }

    // aktualizacja paska HP
    final double hpPercent = hp / 20;
    hpBar.size = Vector2(200 * hpPercent, 12);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    // trafienie pociskiem gracza
    if (other is Bullet) {
      hp--;
      other.removeFromParent();

      if (hp <= 0) {
        gameRef.addScoreBoss();
        gameRef.bossActive = false;
        removeFromParent();
      }
    }

    // kolizja z graczem = natychmiastowy game over
    if (other is OrlikPlayer) {
      gameRef.loseLife();
      gameRef.bossActive = false;
      removeFromParent();
    }
  }
}
