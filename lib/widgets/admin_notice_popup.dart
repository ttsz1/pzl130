import 'package:flutter/material.dart';

class AdminNoticePopup extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;

  const AdminNoticePopup({
    super.key,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        "Komunikat od administratora",
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            "Zapoznałem się",
            style: TextStyle(color: Colors.lightGreenAccent),
          ),
        ),
      ],
    );
  }
}
