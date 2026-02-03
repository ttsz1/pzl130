import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordWithPinScreen extends StatefulWidget {
  const ResetPasswordWithPinScreen({super.key});

  @override
  State<ResetPasswordWithPinScreen> createState() => _ResetPasswordWithPinScreenState();
}

class _ResetPasswordWithPinScreenState extends State<ResetPasswordWithPinScreen> {
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _pinSent = false;
  bool _loading = false;

  Future<void> _sendPin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj adres e-mail')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      setState(() => _pinSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kod PIN został wysłany na e-mail!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final code = _pinController.text.trim();
    final newPassword = _passwordController.text.trim();
    final email = _emailController.text.trim();

    if (email.isEmpty || code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wpisz e-mail, kod PIN i nowe hasło!')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.recovery,
        token: code,
        email: email, // <- to jest KLUCZOWE!
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod PIN jest nieprawidłowy lub wygasł')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset hasła — kod PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              enabled: !_pinSent, // nie pozwól zmienić po wysłaniu PIN
            ),
            const SizedBox(height: 16),
            if (!_pinSent) ...[
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _sendPin,
                child: const Text('Wyślij kod PIN'),
              ),
            ] else ...[
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'Kod PIN z maila'),
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
                onPressed: _resetPassword,
                child: const Text('Ustaw nowe hasło'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}