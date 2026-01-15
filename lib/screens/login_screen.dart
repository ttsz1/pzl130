import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logowanie')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
            );
          },
          child: const Text('Nie pamiętam hasła'),
        ),
      ),
    );
  }
}