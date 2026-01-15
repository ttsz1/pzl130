import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final code = _codeController.text.trim();
    final newPassword = _passwordController.text.trim();

    try {
      // 1. Zweryfikuj kod (PIN) z maila
      final res = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.recovery,
        token: code,
      );

      // 2. Jeśli OK, ustaw nowe hasło
      if (res.user != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Sukces!'),
            content: Text('Hasło zostało zmienione. Możesz się zalogować.'),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Błąd'),
            content: Text('Kod jest nieprawidłowy lub wygasł.'),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Błąd'),
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowe hasło')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Kod z maila'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nowe hasło'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submit,
              child: const Text('Ustaw nowe hasło'),
            ),
          ],
        ),
      ),
    );
  }
}