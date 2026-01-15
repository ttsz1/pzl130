import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../services/notes_service.dart';
import 'presentation_notes_bottomsheet.dart';

class PdfSliderView extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfSliderView({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfSliderView> createState() => _PdfSliderViewState();
}

class _PdfSliderViewState extends State<PdfSliderView> {
  final PdfViewerController _controller = PdfViewerController();
  final NotesService _notesService = NotesService();

  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _notesService.ensureNoteExists(widget.pdfUrl);
  }

  void _openNotes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PresentationNotesBottomSheet(
        pdfUrl: widget.pdfUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress =
    _totalPages > 1 ? _currentPage / _totalPages : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt),
            onPressed: _openNotes,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SfPdfViewer.network(
              widget.pdfUrl,
              controller: _controller,
              pageLayoutMode: PdfPageLayoutMode.single,
              scrollDirection: PdfScrollDirection.horizontal,
              enableDoubleTapZooming: true,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              onDocumentLoaded: (details) {
                setState(() {
                  _totalPages = details.document.pages.count;
                  _currentPage = _controller.pageNumber;
                });
              },
              onPageChanged: (details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            ),
          ),

          // Pasek postępu
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              color: Colors.blueAccent,
              minHeight: 4,
            ),
          ),

          // Przyciski Dalej / Wstecz / Zamknij
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  heroTag: "prev",
                  backgroundColor: Colors.white24,
                  onPressed: _currentPage > 1
                      ? () => _controller.previousPage()
                      : null,
                  child: const Icon(Icons.arrow_back),
                ),
                Text(
                  "$_currentPage / $_totalPages",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                FloatingActionButton(
                  heroTag: "next",
                  backgroundColor: Colors.white24,
                  onPressed: _currentPage < _totalPages
                      ? () => _controller.nextPage()
                      : null,
                  child: const Icon(Icons.arrow_forward),
                ),
                FloatingActionButton(
                  heroTag: "exit",
                  backgroundColor: Colors.redAccent,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
