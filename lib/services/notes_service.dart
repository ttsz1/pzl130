import 'package:supabase_flutter/supabase_flutter.dart';

class NotesService {
  final supabase = Supabase.instance.client;

  Future<void> ensureNoteExists(String pdfUrl) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('presentation_notes').upsert({
      'pdf_url': pdfUrl,
      'user_id': userId,
      'note': '',
    });
  }

  Future<String> loadNote(String pdfUrl) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return "";

    final response = await supabase
        .from('presentation_notes')
        .select('note')
        .eq('pdf_url', pdfUrl)
        .eq('user_id', userId)
        .maybeSingle();

    return response?['note'] ?? "";
  }

  Future<void> saveNote(String pdfUrl, String text) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('presentation_notes')
        .update({
      'note': text,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('pdf_url', pdfUrl)
        .eq('user_id', userId);
  }
}
