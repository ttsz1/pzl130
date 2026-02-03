import 'package:flutter/material.dart';
import '../secure_storage_service.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final pinController = TextEditingController();

  Future<void> savePin() async {
    if (pinController.text.length != 4) return;

    await SecureStorageService.savePin(pinController.text);

    Navigator.pushReplacementNamed(context, "/intro");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ustaw PIN")),
      body: Center(
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: pinController,
                maxLength: 4,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(counterText: ""),
              ),
              ElevatedButton(
                onPressed: savePin,
                child: const Text("Zapisz PIN"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
