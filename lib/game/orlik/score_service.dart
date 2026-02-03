import 'package:supabase_flutter/supabase_flutter.dart';

class ScoreService {
  final supabase = Supabase.instance.client;

  Future<int> getHighScore(String userId) async {
    final res = await supabase
        .from('scores')
        .select('highscore')
        .eq('user_id', userId)
        .maybeSingle();

    return res?['highscore'] ?? 0;
  }

  Future<void> updateHighScore(String userId, int score) async {
    await supabase.from('scores').upsert({
      'user_id': userId,
      'highscore': score,
    });
  }
}
