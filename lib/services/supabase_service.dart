// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Pobierz wszystkie scenariusze
  static Future<List<Map<String, dynamic>>> getScenarios() async {
    try {
      final response = await _client
          .from('scenarios')
          .select('id, name, description, difficulty_level')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd pobierania scenariuszy: $e');
      rethrow;
    }
  }

  // Pobierz kroki dla konkretnego scenariusza
  static Future<List<Map<String, dynamic>>> getStorySteps(String scenarioId) async {
    try {
      final response = await _client
          .from('story_steps')
          .select('*')
          .eq('scenario_id', scenarioId)
          .order('step_number', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd pobierania kroków scenariusza: $e');
      rethrow;
    }
  }
}