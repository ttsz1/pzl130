import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestPinScreen extends StatefulWidget {
  const RequestPinScreen({super.key});

  @override
  State<RequestPinScreen> createState() => _RequestPinScreenState();
}

class _RequestPinScreenState extends State<RequestPinScreen> {
  final _emailController = TextEditingController();

  Future<void> _requestPin() async {
    final email = _emailController.text.trim();
    final res = await http.post(
      Uri.parse('https://iwnnwqbtmpeqhdysoewk.supabase.co/functions/v1/generate-pin'),
      headers: {'Content-Type': 'application/json'},
      body: '{"email":"$email"}',
    );

    if (res.statusCode == 200) {
      Navigator.pushNamed(context, '/verify-pin', arguments: email);
    } else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Błąd'),
          content: Text('Nie udało się wysłać kodu PIN.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset hasła')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _requestPin, child: const Text('Wyślij kod PIN')),
          ],
        ),
      ),
    );
  }
}
