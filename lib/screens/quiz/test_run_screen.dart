import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestRunScreen extends StatefulWidget {
  final String category;
  const TestRunScreen({super.key, required this.category});

  @override
  State<TestRunScreen> createState() => _TestRunScreenState();
}

class _TestRunScreenState extends State<TestRunScreen> {
  final client = Supabase.instance.client;
  List<Map<String, dynamic>> questions = [];
  Map<String, String> userAnswers = {};
  bool isLoaded = false;
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await client
          .from('test_questions')
          .select()
          .eq('category', widget.category);

      setState(() {
        questions = (response as List).cast<Map<String, dynamic>>();
        isLoaded = true;
      });
    } catch (e) {
      debugPrint("❌ Błąd ładowania pytań: $e");
    }
  }

  Future<void> _submitTest() async {
    if (isSubmitted) return;

    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    int score = 0;
    for (final q in questions) {
      final id = q['id']?.toString() ?? '';
      final correct = q['correct_option']?.toString() ?? '';
      final selected = userAnswers[id];
      if (selected != null && selected == correct) score++;
    }

    try {
      final resultInsert = await client
          .from('test_results')
          .insert({
        'user_id': userId,
        'category': widget.category,
        'score': score,
        'total': questions.length,
        'attempted_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      final resultId = resultInsert['id']?.toString() ?? '';

      for (final q in questions) {
        final id = q['id']?.toString() ?? '';
        final selected = userAnswers[id] ?? '';
        final correct = q['correct_option']?.toString() ?? '';
        final question = q['question']?.toString() ?? '';
        final correctText = q['option_${correct.toLowerCase()}']?.toString() ?? '';
        final selectedText = q['option_${selected.toLowerCase()}']?.toString() ?? '';

        await client.from('test_result_answers').insert({
          'result_id': resultId,
          'question': question,
          'correct_option': correct,
          'selected_option': selected,
          'correct_text': correctText,
          'selected_text': selectedText,
        });
      }

      setState(() => isSubmitted = true);
      debugPrint("✅ Zapisano wynik i odpowiedzi testu");

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Test zakończony"),
          content: Text("Wynik: $score / ${questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Powrót"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("❌ Błąd zapisu wyników testu: $e");
    }
  }

  Widget _buildQuestionCard(Map<String, dynamic> q, int index) {
    final id = q['id']?.toString() ?? '';
    final selected = userAnswers[id];
    final isLocked = isSubmitted;
    final explanation = q['explanation']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pytanie ${index + 1}: ${q['question']?.toString() ?? ''}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...['A', 'B', 'C', 'D'].map((letter) {
              final option = q['option_${letter.toLowerCase()}']?.toString() ?? '';
              final correct = q['correct_option']?.toString() ?? '';
              final isCorrect = isSubmitted && letter == correct;
              final isWrongSelected = isSubmitted && selected == letter && selected != correct;

              return RadioListTile<String>(
                value: letter,
                groupValue: selected,
                onChanged: isLocked ? null : (val) => setState(() => userAnswers[id] = val!),
                title: Text("$letter) $option"),
                tileColor: isCorrect
                    ? Colors.green.withOpacity(0.2)
                    : isWrongSelected
                    ? Colors.red.withOpacity(0.2)
                    : null,
              );
            }).toList(),
            if (isSubmitted && explanation.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text("📝 Wyjaśnienie: $explanation",
                  style: const TextStyle(color: Colors.black54)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Test: ${widget.category}")),
        body: const Center(child: Text("Brak pytań w tej kategorii.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Test: ${widget.category}")),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ...questions.asMap().entries.map((entry) => _buildQuestionCard(entry.value, entry.key)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("Zakończ test"),
              onPressed: isSubmitted ? null : _submitTest,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
