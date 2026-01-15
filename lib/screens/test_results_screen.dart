import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({super.key});

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    final res = await supabase
        .from('test_results')
        .select()
        .eq('user_id', userId)
        .order('attempted_at', ascending: false);

    setState(() {
      results = (res as List).cast<Map<String, dynamic>>();
      isLoading = false;
    });
  }

  Future<void> _confirmAndDeleteAllResults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Usuń wszystkie testy'),
        content: const Text('Czy na pewno chcesz usunąć wszystkie podejścia do testów?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Usuń')),
        ],
      ),
    );

    if (confirmed == true) {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      try {
        await supabase.from('test_results').delete().eq('user_id', userId);
        setState(() => results.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wszystkie podejścia do testów zostały usunięte.')),
        );
      } catch (e) {
        debugPrint('❌ Błąd przy usuwaniu testów: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: nie udało się usunąć testów.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje testy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Usuń wszystkie',
            onPressed: _confirmAndDeleteAllResults,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
          ? const Center(child: Text('Brak podejść do testów.'))
          : ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          final title = result['title'] ?? 'Test';
          final score = result['score'] ?? 0;
          final total = result['total'] ?? 1;
          final date = result['attempted_at'];
          final formattedDate = date != null
              ? date.toString().substring(0, 10)
              : 'brak daty';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: ListTile(
              tileColor: _getTileColor(score, total).withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: _buildAnimatedCircle(score, total),
              title: Text('$title ($score / $total)'),
              subtitle: Text('Ocena: ${_getLabel(score, total)} • Data: $formattedDate'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Możesz tu dodać nawigację do ekranu podglądu testu
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funkcja podglądu jeszcze niegotowa.')),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getLabel(int score, int total) {
    final percent = (score / total) * 100;
    if (percent < 70) return 'Unsat';
    if (percent < 80) return 'Fair';
    if (percent < 90) return 'Good';
    return 'Excellent';
  }

  Color _getTileColor(int score, int total) {
    final percent = (score / total) * 100;
    if (percent < 70) return Colors.red;
    if (percent < 80) return Colors.orange;
    if (percent < 90) return Colors.blue;
    return Colors.green;
  }

  Widget _buildAnimatedCircle(int score, int total) {
    final percent = (score / total * 100).round();
    final color = _getTileColor(score, total);
    final isUnsat = percent < 70;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: isUnsat ? 42 : 38,
      height: isUnsat ? 42 : 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: isUnsat
            ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]
            : [],
      ),
      child: Center(
        child: Text(
          '$percent%',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
