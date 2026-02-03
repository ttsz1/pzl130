import 'package:flutter/material.dart';
import 'timecalk_screen.dart';
import 'metar_screen.dart';
import 'orlik_game_screen.dart';
import '../match3_screen.dart'; // ★ dodaj import

class UtilitiesScreen extends StatelessWidget {
  const UtilitiesScreen({super.key});

  void _goTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _UtilityItem(
        title: 'TimeCalk',
        description: 'Kalkulator czasu hh:mm, h, m',
        icon: Icons.access_time,
        color: Colors.blueGrey,
        onTap: () => _goTo(context, const TimeCalkScreen()),
      ),
      _UtilityItem(
        title: 'METAR',
        description: 'Aktualne METAR dla wybranych lotnisk',
        icon: Icons.cloud,
        color: Colors.lightBlue,
        onTap: () => _goTo(context, const MetarScreen()),
      ),

      // ★★★ NOWY ELEMENT LISTY — TRYB ZBIERZ 3 ★★★
      _UtilityItem(
        title: 'Tryb: ZBIERZ 3',
        description: 'Nowa gra logiczna — zbierz śmigła!',
        icon: Icons.grid_3x3,
        color: Colors.green,
        onTap: () => _goTo(context, const Match3Screen()),
      ),

      _UtilityItem(
        title: 'orlik vs sahed',
        description: 'trochę rozrywki',
        icon: Icons.airplanemode_active,
        color: Colors.orange,
        onTap: () => _goTo(context, const OrlikGameScreen(userId: '1')),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Utilities')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final it = items[i];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: it.color.withOpacity(0.2),
                child: Icon(it.icon, color: it.color),
              ),
              title: Text(
                it.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(it.description),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: it.onTap,
            ),
          );
        },
      ),
    );
  }
}

class _UtilityItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _UtilityItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
