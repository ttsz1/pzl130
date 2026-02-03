import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizReviewScreen extends StatefulWidget {
  final String resultId;
  final String quizTitle;

  const QuizReviewScreen({
    super.key,
    required this.resultId,
    required this.quizTitle,
  });

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
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
          .from('open_result_answers')
          .select('question, correct_option, selected_option')
          .eq('result_id', widget.resultId);

      answers = (res as List)
          .map((e) => {
        'question': e['question'] ?? '',
        'correct': e['correct_option'] ?? '',
        'selected': e['selected_option'] ?? '',
      })
          .toList();

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ Błąd: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Podejście: ${widget.quizTitle}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : answers.isEmpty
          ? const Center(child: Text('Brak odpowiedzi do wyświetlenia.'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: answers.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = answers[index];
          final question = item['question'];
          final correct = item['correct'];
          final selected = item['selected'];
          final isCorrect = correct == selected;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${index + 1}. $question',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('✅ Poprawna: $correct'),
              Text('🙋 Twoja: $selected'),
              Text(
                isCorrect ? '🎯 Trafione' : '🚫 Nietrafione',
                style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.red),
              ),
            ],
          );
        },
      ),
    );
  }
}
