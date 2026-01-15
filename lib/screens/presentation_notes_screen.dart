import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notes_service.dart';

class PresentationNotesScreen extends StatefulWidget {
  final String pdfUrl;

  const PresentationNotesScreen({
    super.key,
    required this.pdfUrl,
  });

  @override
  State<PresentationNotesScreen> createState() =>
      _PresentationNotesScreenState();
}

class _PresentationNotesScreenState extends State<PresentationNotesScreen> {
  final NotesService _notesService = NotesService();
  late TextEditingController _controller;

  bool _isDirty = false;
  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _load();

    // jeśli chcesz autosave, zostaw to, jeśli nie – usuń
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

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

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

    return true;
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Moje notatki"),
          backgroundColor: Colors.black,
          actions: [
            TextButton(
              onPressed: () async {
                await _save();
                Navigator.pop(context);
              },
              child: const Text(
                "Zapisz",
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
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
      ),
    );
  }
}
