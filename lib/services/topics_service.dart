import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/topic.dart';

class TopicsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Topic>> getTopics() async {
    final data = await _supabase
        .from('topics')
        .select()
        .order('created_at', ascending: true);

    return (data as List<dynamic>)
        .map((item) => Topic.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
