import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'scenario_steps_admin_screen.dart';

class StandupEpAdminScreen extends StatefulWidget {
  const StandupEpAdminScreen({super.key});

  @override
  State<StandupEpAdminScreen> createState() => _StandupEpAdminScreenState();
}

class _StandupEpAdminScreenState extends State<StandupEpAdminScreen> {
  final client = Supabase.instance.client;
  List<Map<String, dynamic>> scenarios = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    try {
      final response =
      await client.from('scenarios').select('*').order('created_at', ascending: false);

      setState(() {
        scenarios = List<Map<String, dynamic>>.from(response);
        isLoaded = true;
      });
    } catch (e) {
      setState(() => isLoaded = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd ładowania scenariuszy: $e')),
      );
    }
  }

  void _showCreateScenarioDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateScenarioDialog(),
    ).then((_) => _loadScenarios());
  }

  void _editScenario(Map<String, dynamic> scenario) {
    showDialog(
      context: context,
      builder: (context) => EditScenarioDialog(scenario: scenario),
    ).then((_) => _loadScenarios());
  }

  Future<void> _deleteScenario(String scenarioId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdzenie'),
        content: const Text('Czy chcesz usunąć ten scenariusz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Usuń', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await client.from('scenarios').delete().eq('id', scenarioId);
        _loadScenarios();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Scenariusz usunięty')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd usuwania scenariusza: $e')),
        );
      }
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFede0c6), Color(0xFF5d7861)],
          ),
        ),
        child: isLoaded
            ? scenarios.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Brak scenariuszy',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showCreateScenarioDialog,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                child: const Text('Utwórz Scenariusz'),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scenarios.length,
          itemBuilder: (context, index) {
            final scenario = scenarios[index];
            final difficulty = scenario['difficulty_level'] ?? 'medium';

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFeed5b7), width: 2)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getDifficultyColor(difficulty),
                  ),
                  child: const Icon(Icons.emergency, color: Colors.white),
                ),
                title: Text(scenario['name'] ?? 'Brak nazwy',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(scenario['description'] ?? 'Brak opisu',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.list_alt, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ScenarioStepsAdminScreen(
                              scenarioId: scenario['id'],
                              scenarioName: scenario['name'],
                            )));
                      },
                      tooltip: 'Edytuj kroki',
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edytuj scenariusz'),
                          ]),
                          onTap: () => _editScenario(scenario),
                        ),
                        PopupMenuItem(
                          child: const Row(children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Usuń', style: TextStyle(color: Colors.red)),
                          ]),
                          onTap: () => _deleteScenario(scenario['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateScenarioDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// *******************************************************************
// CreateScenarioDialog - dialog tworzenia scenariusza

class CreateScenarioDialog extends StatefulWidget {
  const CreateScenarioDialog({super.key});

  @override
  State<CreateScenarioDialog> createState() => _CreateScenarioDialogState();
}

class _CreateScenarioDialogState extends State<CreateScenarioDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedDifficulty = 'medium';
  final client = Supabase.instance.client;
  bool _isLoading = false;

  final List<String> difficulties = ['easy', 'medium', 'hard', 'critical'];

  Future<void> _createScenario() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nazwa scenariusza jest wymagana')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await client.from('scenarios').insert({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'difficulty_level': _selectedDifficulty,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scenariusz utworzony')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Utwórz Nowy Scenariusz'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nazwa scenariusza',
                border: OutlineInputBorder(),
                hintText: 'np. Spadek ciśnienia oleju',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis',
                border: OutlineInputBorder(),
                hintText: 'Opisz sytuację awaryjną',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Poziom trudności',
                border: OutlineInputBorder(),
              ),
              items: difficulties.map((diff) {
                return DropdownMenuItem(value: diff, child: Text(diff));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDifficulty = value ?? 'medium');
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
        ElevatedButton(
          onPressed: _isLoading ? null : _createScenario,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Utwórz'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// *******************************************************************
// EditScenarioDialog - dialog edycji istniejącego scenariusza

class EditScenarioDialog extends StatefulWidget {
  final Map<String, dynamic> scenario;
  const EditScenarioDialog({super.key, required this.scenario});

  @override
  State<EditScenarioDialog> createState() => _EditScenarioDialogState();
}

class _EditScenarioDialogState extends State<EditScenarioDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedDifficulty;
  final client = Supabase.instance.client;
  bool _isLoading = false;

  final List<String> difficulties = ['easy', 'medium', 'hard', 'critical'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.scenario['name']);
    _descriptionController = TextEditingController(text: widget.scenario['description']);
    _selectedDifficulty = widget.scenario['difficulty_level'] ?? 'medium';
  }

  Future<void> _updateScenario() async {
    setState(() => _isLoading = true);
    try {
      await client.from('scenarios').update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'difficulty_level': _selectedDifficulty,
      }).eq('id', widget.scenario['id']);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scenariusz zaktualizowany')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edytuj Scenariusz'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nazwa scenariusza', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Opis', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(labelText: 'Poziom trudności', border: OutlineInputBorder()),
              items: difficulties.map((diff) {
                return DropdownMenuItem(value: diff, child: Text(diff));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedDifficulty = value ?? 'medium');
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateScenario,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Zapisz'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
