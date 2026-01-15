import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestReviewScreen extends StatefulWidget {
  final String resultId;
  final String testTitle;

  const TestReviewScreen({
    super.key,
    required this.resultId,
    required this.testTitle,
  });

  @override
  State<TestReviewScreen> createState() => _TestReviewScreenState();
}

class _TestReviewScreenState extends State<TestReviewScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> answers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    try {
      final res = await supabase
          .from('test_result_answers')
          .select('question, correct_option, selected_option, correct_text, selected_text')
          .eq('result_id', widget.resultId);

      answers = (res as List).map((e) => {
        'question': e['question']?.toString() ?? '',
        'correct': e['correct_option']?.toString() ?? '',
        'selected': e['selected_option']?.toString() ?? '',
        'correctText': e['correct_text']?.toString() ?? '',
        'selectedText': e['selected_text']?.toString() ?? '',
      }).toList();

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ Błąd ładowania odpowiedzi: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test: ${widget.testTitle}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : answers.isEmpty
          ? const Center(child: Text('Brak odpowiedzi do wyświetlenia.'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: answers.length,
        separatorBuilder: (_, __) => const Divider(height: 28),
        itemBuilder: (context, index) {
          final item = answers[index];
          final q = item['question'];
          final correct = item['correct'];
          final selected = item['selected'];
          final correctText = item['correctText'];
          final selectedText = item['selectedText'];
          final isCorrect = correct == selected;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${index + 1}. $q', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('✅ Poprawna: $correct) $correctText'),
              Text('🙋 Twoja: $selected) $selectedText'),
              const SizedBox(height: 4),
              Text(
                isCorrect ? '🎯 Trafione' : '🚫 Nietrafione',
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
