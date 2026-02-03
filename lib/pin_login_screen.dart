import 'package:flutter/material.dart';
import 'package:pzl130/main_menu_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../secure_storage_service.dart';
import '../../screens/login_screen.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final pinController = TextEditingController();
  String? savedPin;

  @override
  void initState() {
    super.initState();
    loadPin();
  }

  void loadPin() async {
    savedPin = await SecureStorageService.getPin();
    setState(() {});
  }

  Future<void> loginWithPin() async {
    if (pinController.text != savedPin) return;

    final creds = await SecureStorageService.getCredentials();
    final email = creds["email"];
    final password = creds["password"];

    if (email == null || password == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    final res = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    Navigator.pushReplacementNamed(context, "/intro");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wpisz PIN")),
      body: Center(
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: pinController,
                maxLength: 4,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(counterText: ""),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: loginWithPin,
                child: const Text("Zaloguj"),
              ),

              const SizedBox(height: 24),

              // 🔥 NOWY PRZYCISK — ZAPOMNIAŁEM PINU
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                  );
                },
                child: const Text(
                  "Zapomniałem PIN‑u",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
