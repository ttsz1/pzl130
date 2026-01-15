import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyPinScreen extends StatefulWidget {
  const VerifyPinScreen({super.key});

  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final _pinController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _verifyAndReset(String email) async {
    final pin = _pinController.text.trim();
    final password = _passwordController.text.trim();
    final supabase = Supabase.instance.client;

    try {
      // 🔐 Weryfikacja kodu PIN
      final response = await supabase.auth.verifyOTP(
        tokenHash: pin,
        type: OtpType.recovery,
        email: email,
      );

      if (response.user == null) {
        throw Exception('Niepoprawny kod PIN lub wygasł.');
      }

      // 🔒 Zmiana hasła
      final update = await supabase.auth.updateUser(
        UserAttributes(password: password),
      );

      if (update.user == null) {
        throw Exception('Nie udało się ustawić hasła.');
      }

      // ✅ Sukces → przekierowanie
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Błąd'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Weryfikacja PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Email: $email'),
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: 'Kod PIN'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nowe hasło'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _verifyAndReset(email),
              child: const Text('Zmień hasło'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
