import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        _showError('Niepoprawne dane logowania.');
        setState(() => _loading = false);
        return;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('is_approved')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        _showError('Nie znaleziono profilu użytkownika.');
        setState(() => _loading = false);
        return;
      }

      if (profile['is_approved'] == true) {
        // ✅ użytkownik zatwierdzony → przejście dalej
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showError('Twoje konto nie zostało jeszcze zatwierdzone przez administratora.');
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Błąd logowania: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Błąd'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Hasło'),
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('Zaloguj się'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/reset');
                },
                child: const Text('Nie pamiętasz hasła?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Nie masz konta? Zarejestruj się'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/set-new-password');
                },
                child: const Text('Masz kod z maila? Ustaw nowe hasło'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}