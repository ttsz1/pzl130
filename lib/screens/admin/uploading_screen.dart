import 'package:flutter/material.dart';

class UploadingScreen extends StatefulWidget {
  final Future<void> Function() uploadTask;

  const UploadingScreen({super.key, required this.uploadTask});

  @override
  State<UploadingScreen> createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  double progress = 0;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 30));
      setState(() => progress = i / 100);
    }

    await widget.uploadTask();
    setState(() => isDone = true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pop(context); // wraca do poprzedniego
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wysyłanie wyników')),
      body: Center(
        child: isDone
            ? const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('Wyniki zostały zapisane.'),
          ],
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Zapisuję dane...'),
            const SizedBox(height: 20),
            CircularProgressIndicator(value: progress),
            const SizedBox(height: 10),
            Text('${(progress * 100).round()}%'),
          ],
        ),
      ),
    );
  }
}
