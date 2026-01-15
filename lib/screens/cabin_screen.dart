import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CabinScreen extends StatelessWidget {
  const CabinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kabina"),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: SvgPicture.asset(
          "assets/cockpit/cockpit.svg",
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
