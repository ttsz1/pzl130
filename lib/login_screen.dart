import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        throw Exception('Nieprawidłowy email lub hasło');
      }

      final profileRes = await supabase
          .from('profiles')
          .select('is_approved, first_name, last_name, title, is_admin')
          .eq('id', user.id)
          .single();

      final isApproved = profileRes['is_approved'] as bool? ?? false;
      if (!isApproved) {
        await supabase.auth.signOut();
        throw Exception('Twoje konto nie zostało zatwierdzone przez administratora.');
      }

      final firstName = profileRes['first_name'] as String? ?? '';
      final lastName  = profileRes['last_name']  as String? ?? '';
      final title     = profileRes['title']      as String? ?? '';
      final isAdmin   = profileRes['is_admin']   as bool? ?? false;

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UserHomeScreen(
              firstName: firstName,
              lastName: lastName,
              title: title,
              isAdmin: isAdmin,
            ),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Błąd logowania: $error')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Hasło'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Zaloguj się'),
              onPressed: isLoading ? null : _login,
            ),
          ],
        ),
      ),
    );
  }
}
