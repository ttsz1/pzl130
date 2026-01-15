import 'package:flutter/material.dart';

class NotesFloatingWindow extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onChanged;
  final int page;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const NotesFloatingWindow({
    super.key,
    required this.initialText,
    required this.onChanged,
    required this.page,
    required this.totalPages,
    required this.onNext,
    required this.onPrev,
  });

  @override
  State<NotesFloatingWindow> createState() => _NotesFloatingWindowState();
}

class _NotesFloatingWindowState extends State<NotesFloatingWindow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.only(bottom: 80, right: 20),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // GÓRA OKIENKA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Strona ${widget.page} / ${widget.totalPages}",
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // PRZYCISKI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.page > 1 ? widget.onPrev : null,
                  child: const Text("Poprzednia"),
                ),
                ElevatedButton(
                  onPressed: widget.page < widget.totalPages ? widget.onNext : null,
                  child: const Text("Następna"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // NOTATKI
            TextField(
              controller: _controller,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                hintText: "Notatki...",
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
