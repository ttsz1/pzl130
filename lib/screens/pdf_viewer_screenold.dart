import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // WAŻNE: upewnij się, że URL jest poprawnie zakodowany
      final encodedUrl = Uri.encodeFull(widget.url);
      print("Pobieram PDF z: $encodedUrl");

      final response = await http.get(Uri.parse(encodedUrl));

      if (response.statusCode != 200) {
        throw Exception("Błąd pobierania PDF. Kod: ${response.statusCode}");
      }

      // Pobranie katalogu tymczasowego — działa TYLKO po initState
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf");

      await file.writeAsBytes(response.bodyBytes);

      print("PDF zapisany w: ${file.path}");

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print("Błąd pobierania PDF: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Błąd pobierania PDF: $e")),
        );
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath == null
          ? const Center(child: Text("Nie udało się otworzyć PDF"))
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
