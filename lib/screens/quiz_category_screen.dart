import 'package:flutter/material.dart';
import '../models/quiz_category.dart';
import 'quiz_screen.dart';

class QuizCategoryScreen extends StatelessWidget {
  final List<QuizCategory> categories = const [
    QuizCategory(name: 'Engine', icon: Icons.local_gas_station),
    QuizCategory(name: 'Starting', icon: Icons.flash_on),
    QuizCategory(name: 'Fuel', icon: Icons.local_fire_department),
    QuizCategory(name: 'Winds', icon: Icons.air),
    QuizCategory(name: 'Acceleration Limits', icon: Icons.speed),
    QuizCategory(name: 'Intentional Spin Entry', icon: Icons.sync),
    QuizCategory(name: 'Temperature & Humidity', icon: Icons.device_thermostat),
    QuizCategory(name: 'Prohibited Maneuvers', icon: Icons.warning),
    QuizCategory(name: 'Attitude Limitations', icon: Icons.explore),
    QuizCategory(name: 'PCL Movement Limitations', icon: Icons.compare_arrows),
    QuizCategory(name: 'Airspeed Limitations', icon: Icons.speed_outlined),
  ];

  void _openQuiz(BuildContext context, QuizCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz - Kategorie")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final category = categories[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(category.icon, size: 28, color: Colors.blueGrey),
              title: Text(category.name, style: const TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _openQuiz(context, category),
            ),
          );
        },
      ),
    );
  }
}
