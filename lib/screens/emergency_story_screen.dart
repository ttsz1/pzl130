import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class EmergencyStoryScreen extends StatefulWidget {
  final String scenarioId;
  final String scenarioName;
  final String? finalSuccessText;
  final String? finalFailureText;

  const EmergencyStoryScreen({
    super.key,
    required this.scenarioId,
    required this.scenarioName,
    this.finalSuccessText,
    this.finalFailureText,
  });

  @override
  State<EmergencyStoryScreen> createState() => _EmergencyStoryScreenState();
}

class _EmergencyStoryScreenState extends State<EmergencyStoryScreen> {
  int currentStep = 0;
  late Future<List<Map<String, dynamic>>> _stepsFuture;
  List<Map<String, dynamic>> _steps = [];

  @override
  void initState() {
    super.initState();
    _stepsFuture = SupabaseService.getStorySteps(widget.scenarioId);
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    try {
      final steps = await SupabaseService.getStorySteps(widget.scenarioId);
      setState(() => _steps = steps);
    } catch (e) {
      print('Błąd ładowania kroków: $e');
    }
  }

  void _moveToStep(int stepNum) {
    setState(() {
      currentStep = stepNum;
    });
  }

  Widget _buildEndScreen(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle,
              size: 100,
              color: message == widget.finalFailureText ? Colors.red : Colors.green),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => currentStep = 0),
            child: const Text('Spróbuj ponownie'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Wybierz inny scenariusz'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageDialog(String url) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network(url, fit: BoxFit.contain),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Wróć'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenarioName),
        backgroundColor: const Color(0xFF3d4538),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFede0c6), Color(0xFF5d7861)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _stepsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Błąd: ${snapshot.error}'));
            }
            if (_steps.isEmpty) {
              return const Center(child: Text('Brak kroków w scenariuszu'));
            }

            // Obsługa kroków zakończenia
            if (currentStep == 666) {
              return _buildEndScreen(widget.finalFailureText ?? 'Nieudane zakończenie');
            }
            if (currentStep == 777) {
              return _buildEndScreen(widget.finalSuccessText ?? 'Udało się!');
            }
            if (currentStep >= _steps.length || currentStep < 0) {
              return const Center(child: Text('Nieprawidłowy krok'));
            }

            final current = _steps[currentStep];
            final question = current['question'] ?? 'Pytanie';
            final optionsRaw = current['options'] as List;
            final options = optionsRaw.map<Map<String, dynamic>>((o) => Map<String, dynamic>.from(o as Map)).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Krok ${currentStep + 1} z ${_steps.length}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentStep + 1) / _steps.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    question,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  ...options.asMap().entries.map((entry) {
                    final i = entry.key;
                    final opt = entry.value;
                    final imageUrl = opt['imageUrl'] as String?;
                    final nextStep = opt['nextStep'] as int?;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        onPressed: () async {
                          if (imageUrl != null && imageUrl.isNotEmpty) {
                            await _showImageDialog(imageUrl);
                            if (nextStep != null && nextStep != currentStep) {
                              _moveToStep(nextStep);
                            }
                          } else if (nextStep != null) {
                            _moveToStep(nextStep);
                          }
                        },
                        child: Text(opt['text'] ?? ''),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
