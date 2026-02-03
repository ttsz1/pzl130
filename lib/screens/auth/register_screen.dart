import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final titleController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> _register() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final title = titleController.text.trim();

    // Walidacja pól
    if ([email, password, username, firstName, lastName].any((v) => v.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie wymagane pola')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      // 1. Rejestracja użytkownika
      final authRes = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // 2. Poczekaj, aż użytkownik będzie dostępny w bazie
      await Future.delayed(const Duration(seconds: 1));

      // 3. Pobierz id użytkownika z backendu
      final userRes = await supabase.auth.getUser();
      final userId = userRes.user?.id;

      if (userId == null) {
        throw Exception('Nie udało się pobrać identyfikatora użytkownika.');
      }

      // 4. Dodaj dane do tabeli profiles
      await supabase.from('profiles').insert({
        'id': userId,
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'title': title.isEmpty ? null : title,
        'is_admin': false,
        'is_approved': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Rejestracja zakończona pomyślnie!')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Błąd rejestracji: $error')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text('Wypełnij dane użytkownika:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Hasło'), obscureText: true),
            const SizedBox(height: 16),
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Nazwa użytkownika')),
            TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Imię')),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Nazwisko')),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tytuł (opcjonalny)')),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Utwórz konto'),
              onPressed: isLoading ? null : _register,
            ),
          ],
        ),
      ),
    );
  }
}
