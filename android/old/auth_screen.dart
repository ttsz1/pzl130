import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        _showError('Niepoprawne dane logowania.');
        return;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('is_approved')
          .eq('id', user.id)
          .single();

      if (profile['is_approved'] == true) {
        Navigator.pushReplacementNamed(context, '/home'); // lub inny ekran główny
      } else {
        _showError('Konto oczekuje zatwierdzenia przez administratora.');
      }
    } catch (e) {
      _showError('Błąd logowania: $e');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Błąd'),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Hasło'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Zaloguj się')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Stwórz nowe konto'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/reset'),
              child: const Text('Zapomniałem hasła'),
            ),
          ],
        ),
      ),
    );
  }
}
