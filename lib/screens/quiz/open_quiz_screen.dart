import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/open_question.dart';

class OpenQuizScreen extends StatefulWidget {
  final String category;
  const OpenQuizScreen({super.key, required this.category});

  @override
  State<OpenQuizScreen> createState() => _OpenQuizScreenState();
}

class _OpenQuizScreenState extends State<OpenQuizScreen> {
  List<OpenQuestion> questions = [];
  int currentIndex = 0;
  int score = 0;
  final TextEditingController _controller = TextEditingController();
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final response = await Supabase.instance.client
        .from('open_questions')
        .select()
        .eq('category', widget.category);

    setState(() {
      questions = (response as List)
          .map((data) => OpenQuestion.fromJson(data))
          .toList();
      isLoaded = true;
    });
  }

  void _submitAnswer() {
    final userAnswer = _controller.text.trim().replaceAll('%', '');
    final correctAnswer = questions[currentIndex].correctValue.trim().replaceAll('%', '');

    if (userAnswer == correctAnswer) score++;
    _controller.clear();

    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Wynik końcowy"),
        content: Text("Zdobyto $score / ${questions.length} punktów."),
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
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Pytanie ${currentIndex + 1} z ${questions.length}", style: const TextStyle(fontSize: 18)),
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
            )
          ],
        ),
      ),
    );
  }
}
