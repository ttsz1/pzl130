import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ScenarioStepsAdminScreen extends StatefulWidget {
  final String scenarioId;
  final String scenarioName;

  const ScenarioStepsAdminScreen({
    super.key,
    required this.scenarioId,
    required this.scenarioName,
  });

  @override
  State<ScenarioStepsAdminScreen> createState() => _ScenarioStepsAdminScreenState();
}

class _ScenarioStepsAdminScreenState extends State<ScenarioStepsAdminScreen> {
  final client = Supabase.instance.client;
  List<Map<String, dynamic>> steps = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    try {
      final response = await client
          .from('story_steps')
          .select('*')
          .eq('scenario_id', widget.scenarioId)
          .order('step_number', ascending: true);
      setState(() {
        steps = List<Map<String, dynamic>>.from(response);
        isLoaded = true;
      });
    } catch (error) {
      setState(() => isLoaded = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd ładowania kroków: $error')),
      );
    }
  }

  void _showAddStepDialog() {
    showDialog(
      context: context,
      builder: (_) => AddEditStepDialog(
        scenarioId: widget.scenarioId,
        nextStepNumber: steps.length + 1,
        onSave: _loadSteps,
      ),
    );
  }

  void _showEditStepDialog(Map<String, dynamic> stepData) {
    showDialog(
      context: context,
      builder: (_) => AddEditStepDialog(
        scenarioId: widget.scenarioId,
        stepData: stepData,
        onSave: _loadSteps,
      ),
    );
  }

  Future<void> _deleteStep(String stepId) async {
    try {
      await client.from('story_steps').delete().eq('id', stepId);
      _loadSteps();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Krok usunięty')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd usuwania: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kroki: ${widget.scenarioName}'),
        backgroundColor: const Color(0xFF3d4538),
      ),
      body: isLoaded
          ? steps.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.format_list_bulleted, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Brak kroków', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showAddStepDialog,
              child: const Text('Dodaj Krok'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.orange),
                child: Center(
                  child: Text('${step['step_number']}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              title: Text(step['question'] ?? 'Brak pytania',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Wrap(
                spacing: 0,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditStepDialog(step),
                    tooltip: 'Edytuj krok',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteStep(step['id']),
                    tooltip: 'Usuń krok',
                  ),
                ],
              ),
            ),
          );
        },
      )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStepDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        tooltip: 'Dodaj krok',
      ),
    );
  }
}

class AddEditStepDialog extends StatefulWidget {
  final String scenarioId;
  final Map<String, dynamic>? stepData;
  final int? nextStepNumber;
  final VoidCallback onSave;

  const AddEditStepDialog({
    super.key,
    required this.scenarioId,
    this.stepData,
    this.nextStepNumber,
    required this.onSave,
  });

  @override
  State<AddEditStepDialog> createState() => _AddEditStepDialogState();
}

class _AddEditStepDialogState extends State<AddEditStepDialog> {
  late final TextEditingController _questionController;

  late final List<TextEditingController> _textControllers;
  late final List<TextEditingController> _imageUrlControllers;
  late final List<TextEditingController> _nextStepControllers;

  late bool _isEditing;
  final client = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.stepData != null;
    _questionController = TextEditingController(text: widget.stepData?['question'] ?? '');

    if (_isEditing) {
      final options = widget.stepData!['options'] as List<dynamic>? ?? [];
      _textControllers = options
          .map((opt) => TextEditingController(text: opt['text']?.toString() ?? ''))
          .toList();
      _imageUrlControllers = options
          .map((opt) => TextEditingController(text: opt['imageUrl']?.toString() ?? ''))
          .toList();
      _nextStepControllers = options
          .map((opt) => TextEditingController(text: opt['nextStep']?.toString() ?? ''))
          .toList();
    } else {
      _textControllers = [TextEditingController(), TextEditingController()];
      _imageUrlControllers = [TextEditingController(), TextEditingController()];
      _nextStepControllers = [TextEditingController(), TextEditingController()];
    }
  }

  void _addOption() {
    setState(() {
      _textControllers.add(TextEditingController());
      _imageUrlControllers.add(TextEditingController());
      _nextStepControllers.add(TextEditingController());
    });
  }

  Future<String?> _uploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final fileBytes = result.files.first.bytes;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.first.name}';

    try {
      await client.storage.from('standup-ep-images').uploadBinary(fileName, fileBytes!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas uploadu obrazu: $e')));
      return null;
    }

    final url = client.storage.from('standup-ep-images').getPublicUrl(fileName);
    return url;
  }

  Future<void> _save() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pytanie jest wymagane')));
      return;
    }
    if (_textControllers.any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pole tekst opcji jest wymagane dla każdej opcji')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final optionsToSave = List.generate(_textControllers.length, (index) {
        int? nextStep;
        try {
          nextStep = int.parse(_nextStepControllers[index].text);
        } catch (_) {
          nextStep = null;
        }

        return {
          'text': _textControllers[index].text,
          'imageUrl': _imageUrlControllers[index].text.isNotEmpty
              ? _imageUrlControllers[index].text
              : null,
          'nextStep': nextStep,
        };
      });

      if (_isEditing) {
        await client.from('story_steps').update({
          'question': _questionController.text,
          'options': optionsToSave,
        }).eq('id', widget.stepData!['id']);
      } else {
        await client.from('story_steps').insert({
          'scenario_id': widget.scenarioId,
          'step_number': widget.nextStepNumber,
          'question': _questionController.text,
          'options': optionsToSave,
          'next_steps': optionsToSave.map((_) => 0).toList(),
        });
      }
      widget.onSave();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Krok zapisany')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd zapisu: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var ctrl in _textControllers) {
      ctrl.dispose();
    }
    for (var ctrl in _imageUrlControllers) {
      ctrl.dispose();
    }
    for (var ctrl in _nextStepControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edytuj krok' : 'Dodaj nowy krok'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                  labelText: 'Pytanie', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Opcje:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(_textControllers.length, (index) {
              return Column(
                children: [
                  TextField(
                    controller: _textControllers[index],
                    decoration: InputDecoration(
                        labelText: 'Tekst opcji ${index + 1}',
                        border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imageUrlControllers[index],
                          decoration: InputDecoration(
                              labelText: 'URL obrazka (opcjonalnie)',
                              border: const OutlineInputBorder()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.upload_file),
                        tooltip: 'Upload obrazka',
                        onPressed: () async {
                          final url = await _uploadImage();
                          if (url != null) {
                            setState(() {
                              _imageUrlControllers[index].text = url;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nextStepControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Numer następnego kroku (nextStep)',
                      border: const OutlineInputBorder(),
                      hintText: 'np. 1, 2, 0 (0 - koniec/scenariusz)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(height: 24),
                ],
              );
            }),
            ElevatedButton(
              onPressed: _addOption,
              child: const Text('+ Dodaj opcję'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj')),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditing ? 'Zapisz' : 'Dodaj'),
        ),
      ],
    );
  }
}
