// lib/screens/scenario_selection_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'emergency_story_screen.dart';

class ScenarioSelectionScreen extends StatefulWidget {
  const ScenarioSelectionScreen({super.key});

  @override
  State<ScenarioSelectionScreen> createState() => _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState extends State<ScenarioSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _scenariosFuture;

  @override
  void initState() {
    super.initState();
    _scenariosFuture = SupabaseService.getScenarios();
  }

  void _startScenario(String scenarioId, String scenarioName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmergencyStoryScreen(
          scenarioId: scenarioId,
          scenarioName: scenarioName,
        ),
      ),
    );
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

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Łatwy';
      case 'medium':
        return 'Średni';
      case 'hard':
        return 'Trudny';
      case 'critical':
        return 'Krytyczny';
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standup EP - Wybór Scenariusza'),
        backgroundColor: const Color(0xFF3d4538),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFede0c6),
              Color(0xFF5d7861),
            ],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _scenariosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Błąd: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _scenariosFuture = SupabaseService.getScenarios();
                        });
                      },
                      child: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              );
            }

            final scenarios = snapshot.data ?? [];

            if (scenarios.isEmpty) {
              return const Center(
                child: Text('Brak dostępnych scenariuszy'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: scenarios.length,
              itemBuilder: (context, index) {
                final scenario = scenarios[index];
                final difficulty = scenario['difficulty_level'] ?? 'medium';
                final difficultyColor = _getDifficultyColor(difficulty);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFFeed5b7),
                      width: 2,
                    ),
                  ),
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: InkWell(
                    onTap: () => _startScenario(
                      scenario['id'],
                      scenario['name'],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFbdf0dc),
                            const Color(0xFF3f7256),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  scenario['name'] ?? 'Brak nazwy',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3d4538),
                                    fontFamily: 'Pacifico',
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: difficultyColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getDifficultyLabel(difficulty),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            scenario['description'] ?? 'Brak opisu',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3d4538),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Rozpocznij scenariusz',
                                  style: TextStyle(
                                    color: Color(0xFF3d4538),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF3d4538),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}