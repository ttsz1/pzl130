import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notes_service.dart';

class PresentationNotesBottomSheet extends StatefulWidget {
  final String pdfUrl;

  const PresentationNotesBottomSheet({
    super.key,
    required this.pdfUrl,
  });

  @override
  State<PresentationNotesBottomSheet> createState() =>
      _PresentationNotesBottomSheetState();
}

class _PresentationNotesBottomSheetState
    extends State<PresentationNotesBottomSheet> {
  final NotesService _notesService = NotesService();

  late TextEditingController _controller;
  bool _isDirty = false;
  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _load();

    // Autosave co 5 sekund
    _autosaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isDirty) _save();
    });
  }

  Future<void> _load() async {
    final text = await _notesService.loadNote(widget.pdfUrl);
    _controller.text = text;
    _isDirty = false;
  }

  Future<void> _save() async {
    await _notesService.saveNote(widget.pdfUrl, _controller.text);
    _isDirty = false;
  }

  Future<void> _close() async {
    if (!_isDirty) {
      Navigator.pop(context);
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Zapisać zmiany?"),
        content: const Text("Masz niezapisane zmiany w notatkach."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Nie"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Tak"),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _save();
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.33;

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Górny pasek
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Notatki",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _close,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Pole notatek
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => _isDirty = true,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
