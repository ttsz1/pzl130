import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Podaj email i hasło")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw Exception("Błędne dane logowania");
      }

      // 🔥 Zapis email + hasła
      await SecureStorageService.saveCredentials(email, password);

      // 🔥 Jeśli nie ma PIN → ustawiamy
      final savedPin = await SecureStorageService.getPin();
      if (savedPin == null) {
        Navigator.pushReplacementNamed(context, "/setPin");
        return;
      }

      // 🔥 Jeśli PIN istnieje → wchodzimy
      Navigator.pushReplacementNamed(context, "/intro");

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd logowania: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logowanie")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Hasło"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: Text(isLoading ? "Logowanie..." : "Zaloguj"),
            )
          ],
        ),
      ),
    );
  }
}
