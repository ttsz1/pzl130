import 'package:flutter/material.dart';
import 'test_run_screen.dart'; // Upewnij się, że masz ten plik!

class TestModeScreen extends StatelessWidget {
  const TestModeScreen({super.key});

  final List<String> categories = const [
    'nawigacja ogólna',
    'radionawigacja',
    'masa i wyważenie',
    'osiągi i ograniczenia',
    'planowanie i monitorowanie lotu',
    'procedury operacyjne',
    'wyposażenie pokładowe',
    'łączność lotnicza',
    'meteorologia',
    'prawo lotnicze',
    'cmo',
    'zasady lotu'
  ];

  void _startTest(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestRunScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wybierz kategorię testu")),
      body: ListView.builder(
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: ListTile(
              title: Text(cat, style: const TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _startTest(context, cat),
            ),
          );
        },
      ),
    );
  }
}
