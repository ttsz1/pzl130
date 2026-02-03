import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/open_question.dart';
import '../models/quiz_category.dart';

class QuizScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final supabase = Supabase.instance.client;
  List<OpenQuestion> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoaded = false;
  bool hasError = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await supabase
          .from('open_questions')
          .select()
          .eq('category', widget.category.name);

      if (response == null || response is! List || response.isEmpty) {
        setState(() {
          hasError = true;
          isLoaded = true;
        });
        return;
      }

      final loaded = (response as List)
          .map((data) => OpenQuestion.fromJson(data as Map<String, dynamic>))
          .toList();

      setState(() {
        questions = loaded;
        isLoaded = true;
        hasError = questions.isEmpty;
      });
    } catch (e) {
      debugPrint("❌ Błąd ładowania pytań: $e");
      setState(() {
        hasError = true;
        isLoaded = true;
      });
    }
  }

  Future<void> _submitAnswer() async {
    final input = _controller.text.trim().replaceAll('%', '');
    final correct = questions[currentIndex].correctValue.trim().replaceAll('%', '');
    questions[currentIndex].userAnswer = input;

    if (input == correct) score++;
    _controller.clear();

    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      await _saveResult();
      _showResultDialog();
    }
  }

  Future<void> _saveResult() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final resultRes = await supabase
          .from('open_results')
          .insert({
        'user_id': userId,
        'category': widget.category.name,
        'score': score,
        'total': questions.length,
        'attempted_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      final resultId = resultRes['id'] as String;

      for (final q in questions) {
        await supabase.from('open_result_answers').insert({
          'result_id': resultId,
          'question': q.question,
          'correct_option': q.correctValue,
          'selected_option': q.userAnswer ?? '',
        });
      }

      debugPrint("✅ Wynik i odpowiedzi zapisane.");
    } catch (e) {
      debugPrint("❌ Błąd zapisu wyników: $e");
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Wynik końcowy"),
        content: Text("Zdobyto $score / ${questions.length} punktów."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // screen
            },
            child: const Text("Powrót"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.name)),
        body: const Center(child: Text("Brak pytań lub błąd ładowania.")),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pytanie ${currentIndex + 1} z ${questions.length}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(q.question, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Wpisz wartość",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: const Text("Zatwierdź"),
            ),
          ],
        ),
      ),
    );
  }
}
