import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'standup_ep_admin_screen.dart';

class AdminModeScreen extends StatefulWidget {
  const AdminModeScreen({super.key});

  @override
  State<AdminModeScreen> createState() => _AdminModeScreenState();
}

class _AdminModeScreenState extends State<AdminModeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final client = Supabase.instance.client;

  Map<String, String> userEmails = {};
  Map<String, List<Map<String, dynamic>>> quizResults = {};
  Map<String, List<Map<String, dynamic>>> testResults = {};
  Map<String, Map<String, dynamic>> profiles = {};
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // UWAGA: teraz 5
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final profilesResp = await client.from('profiles').select();
      final quizResp = await client.from('open_results').select().order('attempted_at', ascending: false);
      final testResp = await client.from('test_results').select().order('attempted_at', ascending: false);

      for (final row in profilesResp as List) {
        final uid = row['id'];
        profiles[uid] = row;
        userEmails[uid] = row['email'] ?? uid;
      }

      for (final r in quizResp as List) {
        final uid = r['user_id'];
        quizResults.putIfAbsent(uid, () => []);
        quizResults[uid]!.add(r);
      }

      for (final r in testResp as List) {
        final uid = r['user_id'];
        testResults.putIfAbsent(uid, () => []);
        testResults[uid]!.add(r);
      }

      setState(() => isLoaded = true);
    } catch (e) {
      print("❌ Błąd ładowania: $e");
    }
  }

  String _rate(int score, int total) {
    final percent = (score / total) * 100;
    if (percent < 70) return 'Unsat (U)';
    if (percent < 80) return 'Fair (F)';
    if (percent < 90) return 'Good (G)';
    return 'Excellent (E)';
  }

  Color _colorFor(String rating) {
    switch (rating) {
      case 'Unsat (U)': return Colors.red.shade700;
      case 'Fair (F)': return Colors.redAccent;
      case 'Good (G)': return Colors.amber;
      case 'Excellent (E)': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildResultSection(Map<String, List<Map<String, dynamic>>> data) {
    if (data.isEmpty) return const Center(child: Text("Brak danych."));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: data.entries.map((entry) {
        final uid = entry.key;
        final email = userEmails[uid] ?? uid;
        final latestPerCategory = <String, Map<String, dynamic>>{};

        for (final row in entry.value) {
          final cat = row['category'];
          if (!latestPerCategory.containsKey(cat)) latestPerCategory[cat] = row;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: latestPerCategory.entries.map((catEntry) {
              final r = catEntry.value;
              final score = r['score'];
              final total = r['total'];
              final date = DateTime.tryParse(r['attempted_at']);
              final formatted = date != null ? "${date.day}.${date.month}.${date.year}" : "-";
              final rating = _rate(score, total);
              final color = _colorFor(rating);

              return ListTile(
                leading: Icon(Icons.circle, color: color),
                title: Text(catEntry.key),
                subtitle: Text("Wynik: $score / $total ($rating)\nData: $formatted"),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(String uid, String field, String label) {
    final value = profiles[uid]?[field] ?? false;
    final email = userEmails[uid] ?? uid;

    return SwitchListTile(
      title: Text(email),
      subtitle: Text(label),
      value: value,
      onChanged: (val) async {
        await client.from('profiles').update({field: val}).eq('id', uid);
        setState(() => profiles[uid]![field] = val);
      },
    );
  }

  Widget _buildFlagSection(String fieldKey, String label) {
    if (profiles.isEmpty) return const Center(child: Text("Brak profili."));
    return ListView(
      padding: const EdgeInsets.all(12),
      children: profiles.keys.map((uid) => _buildSwitchTile(uid, fieldKey, label)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Mode Screen"),
        backgroundColor: const Color(0xFF3d4538),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Quiz Results"),
            Tab(text: "Test Results"),
            Tab(text: "User Approval"),
            Tab(text: "Admin Flags"),
            Tab(text: "Standup EP"),
          ],
        ),
      ),
      body: isLoaded
          ? TabBarView(
        controller: _tabController,
        children: [
          _buildResultSection(quizResults),
          _buildResultSection(testResults),
          _buildFlagSection('is_approved', 'Dopuszczony do aplikacji'),
          _buildFlagSection('is_admin', 'Uprawnienia administratora'),
          const StandupEpAdminScreen(), // Nowa zakładka!
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
