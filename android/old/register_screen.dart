import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _titleController = TextEditingController();

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final title = _titleController.text.trim();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'email': email,
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'title': title,
          'is_admin': false,
          'is_approved': false,
        });

        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Rejestracja zakończona'),
            content: Text('Twoje konto zostało utworzone i oczekuje zatwierdzenia przez administratora.'),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Błąd'),
          content: Text('Nie udało się utworzyć konta: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'Imię')),
            TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Nazwisko')),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Stopień naukowy')),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Login')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Hasło'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Stwórz konto'),
            ),
          ],
        ),
      ),
    );
  }
}
