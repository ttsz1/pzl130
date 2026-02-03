import 'package:flutter/material.dart';
import '../../screens/quiz_category_screen.dart';
import '../../screens/admin_mode_screen.dart';
import '../../screens/learning_mode_screen.dart';
import '../../screens/my_results_screen.dart';
import '../../screens/test_mode_screen.dart';
import '../../screens/emergency_story_screen.dart';
import '../../screens/utilities_screen.dart';
import '../../screens/scenario_selection_screen.dart';
import '../../screens/cabin_screen.dart'; // <-- NOWA ZAKŁADKA

class UserHomeScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String title;
  final bool isAdmin;

  const UserHomeScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.isAdmin,
  });

  void _goTo(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> menuItems = [
      _MenuItem(
        label: 'Tryb nauki',
        icon: Icons.flight_takeoff,
        gradient: const LinearGradient(colors: [Color(0xFFadc7b3), Color(0xFF354d36)]),
        onTap: () => _goTo(context, const LearningModeScreen()),
      ),
      _MenuItem(
        label: 'Tryb quizu',
        icon: Icons.airplanemode_active,
        gradient: const LinearGradient(colors: [Color(0xFFeecfa1), Color(0xFFc46536)]),
        onTap: () => _goTo(context, QuizCategoryScreen()),
      ),
      _MenuItem(
        label: 'Tryb testu',
        icon: Icons.cloud,
        gradient: const LinearGradient(colors: [Color(0xFFb1b9c6), Color(0xFF2d3a4a)]),
        onTap: () => _goTo(context, TestModeScreen()),
      ),
      _MenuItem(
        label: 'Moje wyniki',
        icon: Icons.star,
        gradient: const LinearGradient(colors: [Color(0xFFf9d6c1), Color(0xFF8a4b32)]),
        onTap: () => _goTo(context, MyResultsScreen()),
      ),
      _MenuItem(
        label: 'Standup EP',
        icon: Icons.schedule,
        gradient: const LinearGradient(colors: [Color(0xFFbdf0dc), Color(0xFF3f7256)]),
        onTap: () => _goTo(context, const ScenarioSelectionScreen()),
      ),
      _MenuItem(
        label: 'Utilities',
        icon: Icons.build,
        gradient: const LinearGradient(colors: [Color(0xFFc4def1), Color(0xFF2b5c7a)]),
        onTap: () => _goTo(context, const UtilitiesScreen()),
      ),

      // 🔥 NOWA ZAKŁADKA — KABINA
      _MenuItem(
        label: 'Kabina',
        icon: Icons.airline_seat_recline_extra,
        gradient: const LinearGradient(colors: [Color(0xFFd4c7ff), Color(0xFF5a4ea3)]),
        onTap: () => _goTo(context, const CabinScreen()),
      ),//../screens/cabin_screen.dart
    ];

    if (isAdmin) {
      menuItems.add(
        _MenuItem(
          label: 'Tryb admin',
          icon: Icons.military_tech,
          gradient: const LinearGradient(colors: [Colors.redAccent, Colors.deepOrangeAccent]),
          onTap: () => _goTo(context, AdminModeScreen()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PZL-130 Orlik TC-II',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 28,
            color: Color(0xFFeed5b7),
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black38,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF3d4538),
        elevation: 6,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "Witaj, $title $firstName $lastName",
                style: const TextStyle(
                  fontFamily: 'Pacifico',
                  color: Color(0xFFeed5b7),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black54,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            stops: [0, 1],
          ),
        ),
        child: Center(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
            itemCount: menuItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 26),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _FancyMenuCard(item: item);
            },
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  _MenuItem({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

class _FancyMenuCard extends StatelessWidget {
  final _MenuItem item;
  const _FancyMenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(width: 2, color: Color(0xFFeed5b7)),
        ),
        elevation: 11,
        shadowColor: Colors.brown.withOpacity(0.30),
        child: Container(
          decoration: BoxDecoration(
            gradient: item.gradient,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.brown.withOpacity(0.15), width: 2),
          ),
          height: 82,
          child: Row(
            children: [
              const SizedBox(width: 20),
              CircleAvatar(
                radius: 29,
                backgroundColor: Colors.white.withOpacity(0.85),
                child: Icon(
                  item.icon,
                  color: item.gradient.colors[1],
                  size: 38,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF3d4538),
                    fontSize: 23,
                    fontFamily: 'Pacifico',
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.white30,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFeed5b7), size: 28),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

