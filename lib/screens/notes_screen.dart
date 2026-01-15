import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onChanged;
  final int page;
  final int totalPages;
  final Future<String?> Function(int page) loadNote;
  final Future<void> Function(int page, String text) saveNote;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const NotesScreen({
    super.key,
    required this.initialText,
    required this.onChanged,
    required this.page,
    required this.totalPages,
    required this.loadNote,
    required this.saveNote,
    required this.onNext,
    required this.onPrev,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late TextEditingController _controller;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.page;
    _controller = TextEditingController(text: widget.initialText);
  }

  Future<void> _goToPage(int newPage) async {
    // zapisujemy aktualną notatkę
    await widget.saveNote(_currentPage, _controller.text);

    // zmieniamy stronę
    setState(() {
      _currentPage = newPage;
    });

    // ładujemy notatkę dla nowej strony
    final newNote = await widget.loadNote(_currentPage);

    // aktualizujemy pole tekstowe
    _controller.text = newNote ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Notatki — strona $_currentPage/${widget.totalPages}"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await widget.saveNote(_currentPage, _controller.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nawigacja między stronami
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 1
                      ? () async {
                    widget.onPrev();
                    await _goToPage(_currentPage - 1);
                  }
                      : null,
                  child: const Text("Poprzednia"),
                ),
                ElevatedButton(
                  onPressed: _currentPage < widget.totalPages
                      ? () async {
                    widget.onNext();
                    await _goToPage(_currentPage + 1);
                  }
                      : null,
                  child: const Text("Następna"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Pole notatek
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  widget.onChanged(value);
                },
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
