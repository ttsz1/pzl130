import 'package:flutter/material.dart';
import '../services/topics_service.dart';
import '../models/topic.dart';
import 'pdf_viewer_screen.dart';
import 'pdf_slider_view.dart';

class LearningModeScreen extends StatefulWidget {
  const LearningModeScreen({super.key});

  @override
  State<LearningModeScreen> createState() => _LearningModeScreenState();
}

class _LearningModeScreenState extends State<LearningModeScreen> {
  final TopicsService _topicsService = TopicsService();
  late Future<List<Topic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _topicsService.getTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tryb nauki'),
      ),
      body: FutureBuilder<List<Topic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Błąd: ${snapshot.error}'),
            );
          }

          final topics = snapshot.data ?? [];

          if (topics.isEmpty) {
            return const Center(
              child: Text('Brak tematów do wyświetlenia'),
            );
          }

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ListTile(
                title: Text(topic.title),
                subtitle: topic.description != null && topic.description!.isNotEmpty
                    ? Text(topic.description!)
                    : null,
                trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                if (topic.fileUrl == null || topic.fileUrl!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Brak prezentacji dla tego tematu')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfSliderView(
                      pdfUrl: topic.fileUrl!,
                      title: topic.title,
                    ),
                  ),
                );

                  },

              );
            },
          );
        },
      ),
    );
  }
}
