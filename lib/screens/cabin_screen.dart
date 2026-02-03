import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CabinScreen extends StatefulWidget {
  const CabinScreen({super.key});

  @override
  State<CabinScreen> createState() => _CabinScreenState();
}

class _CabinScreenState extends State<CabinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildLeftPanel(),
      endDrawer: _buildRightPanel(),
      appBar: AppBar(
        title: const Text("Kabina"),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // POWIĘKSZANIE + PRZESUWANIE SVG
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(200),
            child: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    "assets/cockpit/cockpit.svg",
                    fit: BoxFit.contain,
                  ),
                ),

                // 🔥 HOTSPOT 1
                Positioned(
                  left: 120,
                  top: 200,
                  width: 120,
                  height: 120,
                  child: GestureDetector(
                    onTap: () => _openHotspot("Lewy panel sterowania"),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // 🔥 HOTSPOT 2
                Positioned(
                  right: 140,
                  top: 220,
                  width: 120,
                  height: 120,
                  child: GestureDetector(
                    onTap: () => _openHotspot("Prawy panel sterowania"),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // 🔥 HOTSPOT 3
                Positioned(
                  left: 180,
                  top: 350,
                  width: 200,
                  height: 150,
                  child: GestureDetector(
                    onTap: () => _openHotspot("Ekran centralny"),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),

          // PRZYCISK LEWY PANEL
          Positioned(
            left: 10,
            top: 10,
            child: ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text("Pulpit Lewy"),
            ),
          ),

          // PRZYCISK PRAWY PANEL
          Positioned(
            right: 10,
            top: 10,
            child: ElevatedButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              child: const Text("Pulpit Prawy"),
            ),
          ),

          // PRZYCISK BRODA
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => _openBroda(context),
                child: const Text("Broda"),
              ),
            ),
          ),

          // 🔥🔥🔥 DUŻY PRZYCISK WSTECZ 🔥🔥🔥
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("WSTECZ"),
            ),
          ),
        ],
      ),
    );
  }

  // PANEL LEWY
  Drawer _buildLeftPanel() {
    return Drawer(
      child: Container(
        color: Colors.black87,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              child: Text("Pulpit Lewy", style: TextStyle(color: Colors.white)),
            ),
            ListTile(title: Text("Opcja 1", style: TextStyle(color: Colors.white))),
            ListTile(title: Text("Opcja 2", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  // PANEL PRAWY
  Drawer _buildRightPanel() {
    return Drawer(
      child: Container(
        color: Colors.black87,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              child: Text("Pulpit Prawy", style: TextStyle(color: Colors.white)),
            ),
            ListTile(title: Text("Opcja A", style: TextStyle(color: Colors.white))),
            ListTile(title: Text("Opcja B", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  // PANEL BRODA
  void _openBroda(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text("Panel Brody", style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              ListTile(title: Text("Opcja X", style: TextStyle(color: Colors.white))),
              ListTile(title: Text("Opcja Y", style: TextStyle(color: Colors.white))),
            ],
          ),
        );
      },
    );
  }

  // PANEL HOTSPOTU
  void _openHotspot(String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(name, style: const TextStyle(color: Colors.white)),
          content: const Text(
            "Tutaj możesz dodać funkcje, dane, animacje, przełączniki itd.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Zamknij", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
