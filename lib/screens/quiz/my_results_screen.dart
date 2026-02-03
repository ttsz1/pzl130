import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'quiz_review_screen.dart';
import 'test_review_screen.dart'; // ⬅️ dodaj import

class MyResultsScreen extends StatefulWidget {
  const MyResultsScreen({super.key});

  @override
  State<MyResultsScreen> createState() => _MyResultsScreenState();
}

class _MyResultsScreenState extends State<MyResultsScreen> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> quizResults = [];
  List<Map<String, dynamic>> testResults = [];
  bool isLoading = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final quizRes = await supabase
        .from('open_results')
        .select()
        .eq('user_id', userId)
        .order('attempted_at', ascending: false);

    final testRes = await supabase
        .from('test_results')
        .select()
        .eq('user_id', userId)
        .order('attempted_at', ascending: false);

    setState(() {
      quizResults = (quizRes as List).cast<Map<String, dynamic>>();
      testResults = (testRes as List).cast<Map<String, dynamic>>();
      isLoading = false;
    });
  }

  Future<void> _deleteAll(String type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Usuń wyniki $type'),
        content: Text('Czy na pewno chcesz usunąć wszystkie podejścia do $type?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Usuń')),
        ],
      ),
    );

    if (confirmed != true) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      if (type == 'quizów') {
        await supabase.from('open_results').delete().eq('user_id', userId);
        setState(() => quizResults.clear());
      } else {
        await supabase.from('test_results').delete().eq('user_id', userId);
        setState(() => testResults.clear());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usunięto wyniki $type.')),
      );
    } catch (e) {
      debugPrint('❌ Błąd przy usuwaniu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje wyniki'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [Tab(text: 'Quizy'), Tab(text: 'Testy')],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              final type = tabController.index == 0 ? 'quizów' : 'testów';
              _deleteAll(type);
            },
            tooltip: 'Usuń wszystkie',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: tabController,
        children: [
          _buildList(quizResults, isQuiz: true),
          _buildList(testResults, isQuiz: false),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> results, {required bool isQuiz}) {
    if (results.isEmpty) {
      return const Center(child: Text('Brak podejść.'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final r = results[index];
        final score = (r['score'] ?? 0) as int;
        final total = (r['total'] ?? 1) as int;

        final percent = (score / total * 100).round();
        final title = isQuiz
            ? r['category']?.toString() ?? 'Quiz'
            : r['title']?.toString() ?? 'Test';

        final dateRaw = r['attempted_at']?.toString();
        final date = (dateRaw != null && dateRaw.length >= 10)
            ? dateRaw.substring(0, 10)
            : 'brak daty';

        final resultId = r['id']?.toString() ?? '';

        return ListTile(
          leading: _buildCircle(percent),
          tileColor: _getColor(percent).withOpacity(0.1),
          title: Text('$title ($score / $total)'),
          subtitle: Text('Ocena: ${_getLabel(percent)} • Data: $date'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            if (isQuiz) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizReviewScreen(
                    resultId: resultId,
                    quizTitle: title,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TestReviewScreen(
                    resultId: resultId,
                    testTitle: title,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }


  String _getLabel(int p) {
    if (p < 70) return 'Unsat';
    if (p < 80) return 'Fair';
    if (p < 90) return 'Good';
    return 'Excellent';
  }

  Color _getColor(int p) {
    if (p < 70) return Colors.red;
    if (p < 80) return Colors.orange;
    if (p < 90) return Colors.blue;
    return Colors.green;
  }

  Widget _buildCircle(int p) {
    final isLow = p < 70;
    final color = _getColor(p);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: isLow ? 42 : 38,
      height: isLow ? 42 : 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: isLow
            ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 10, spreadRadius: 2)]
            : [],
      ),
      child: Center(
        child: Text('$p%', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
