import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'orlik_player.dart';
import 'shahed_drone.dart';
import 'powerup.dart';
import 'hud.dart';
import 'boss_bryza.dart';
import 'boss_bullet.dart';
import 'game_over_overlay.dart';

class OrlikGame extends FlameGame
    with HasCollisionDetection, PanDetector {
  late OrlikPlayer player;
  late Hud hud;

  int score = 0;
  int lives = 3;
  int highScore = 0;

  bool isGameOver = false;

  // boss system
  bool bossActive = false;
  int nextBossScore = 150;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'orlik.png',
      'shahed.png',
      'bullet.png',
      'power_extra_bullet.png',
      'power_fast_fire.png',
      'power_life.png',
      'bryza.png',
    ]);

    // REJESTRACJA OVERLAY GAME OVER
    overlays.addEntry(
      'gameOver',
          (context, game) => GameOverOverlay(game: this),
    );

    // wczytaj high score użytkownika z Supabase
    await loadHighScoreFromSupabase();

    // wczytaj lokalny highscore (fallback)
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highscore') ?? highScore;

    player = OrlikPlayer();
    add(player);

    hud = Hud();
    add(hud);

    hud.updateScore(score);
    hud.updateLives(lives);

    add(TimerComponent(
      period: 1.2,
      repeat: true,
      onTick: spawnDrone,
    ));

    add(TimerComponent(
      period: 6,
      repeat: true,
      onTick: spawnPowerUp,
    ));
  }

  // sterowanie palcem
  @override
  void onPanUpdate(DragUpdateInfo info) {
    final x = info.eventPosition.global.x;
    player.moveTo(x);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // boss co każde 150 punktów
    if (!bossActive && score >= nextBossScore) {
      spawnBoss();
      nextBossScore += 150;
    }
  }

  void spawnDrone() {
    if (bossActive) return;

    final x = Random().nextDouble() * size.x;
    add(ShahedDrone(position: Vector2(x, -60)));
  }

  void spawnPowerUp() {
    if (bossActive) return;

    final x = Random().nextDouble() * size.x;
    final type = PowerUpType.values[Random().nextInt(3)];
    add(PowerUp(type: type, position: Vector2(x, -40)));
  }

  // boss
  void spawnBoss() {
    bossActive = true;
    final x = size.x / 2;
    add(BossBryza(position: Vector2(x, -200)));
  }

  void addScore() {
    score += 10;
    hud.updateScore(score);
  }

  void addScoreBoss() {
    score += 30;
    hud.updateScore(score);
  }

  void loseLife() {
    if (isGameOver) return;

    lives--;
    hud.updateLives(lives);

    if (lives <= 0) {
      gameOver();
    }
  }

  void addLife() {
    lives++;
    hud.updateLives(lives);
  }

  // RESET GRY
  void resetGame() {
    score = 0;
    lives = 3;
    isGameOver = false;
    bossActive = false;
    nextBossScore = 150;

    // usuń wszystkie komponenty z gry
    removeAll(children.toList());

    // załaduj grę od nowa
    onLoad();

    // wznowienie silnika
    resumeEngine();
  }

  // -------------------------------
  //  SUPABASE: HIGH SCORE PER USER
  // -------------------------------

  Future<void> loadHighScoreFromSupabase() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('scores')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data != null) {
      highScore = data['highscore'] ?? 0;
    }
  }

  Future<void> saveHighScoreToSupabase() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final existing = await supabase
        .from('scores')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('scores').insert({
        'user_id': user.id,
        'highscore': highScore,
      });
    } else {
      final oldScore = existing['highscore'] ?? 0;

      if (highScore > oldScore) {
        await supabase
            .from('scores')
            .update({'highscore': highScore})
            .eq('user_id', user.id);
      }
    }
  }

  void gameOver() async {
    isGameOver = true;

    // lokalny zapis
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      highScore = score;
      await prefs.setInt('highscore', highScore);
    }

    // zapis do Supabase
    await saveHighScoreToSupabase();

    pauseEngine();
    overlays.add('gameOver');
  }
}
