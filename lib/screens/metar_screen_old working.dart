import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MetarScreen extends StatefulWidget {
  const MetarScreen({Key? key}) : super(key: key);

  @override
  State<MetarScreen> createState() => _MetarScreenState();
}

class _MetarScreenState extends State<MetarScreen> {
  final List<String> _stations = ['EPRA', 'EPDE', 'EPLB', 'EPMM', 'EPLK', 'EPKK'];
  bool _loading = true;
  String? _error;
  final List<_MetarRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchFromImgw();
  }

  Future<void> _fetchFromImgw() async {
    setState(() {
      _loading = true;
      _error = null;
      _records.clear();
    });

    const rawUrl = 'https://awiacja.imgw.pl/metar-i-taf';
    final fetchUrl = kIsWeb
        ? 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(rawUrl)}'
        : rawUrl;

    try {
      final resp = await http.get(Uri.parse(fetchUrl));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }
      final html = resp.body;

      for (final st in _stations) {
        final rx = RegExp(
          r'(METAR\s+' + st + r'[^\r\n<]+?=)',
          multiLine: true,
        );
        final m = rx.firstMatch(html);
        if (m != null) {
          final line = m.group(1)!.trim();
          final timeMatch = RegExp(r'(\d{6}Z)').firstMatch(line);
          _records.add(_MetarRecord(
            station: st,
            obsTime: timeMatch?.group(1) ?? '',
            rawText: line,
          ));
        } else {
          _records.add(_MetarRecord(
            station: st,
            obsTime: '',
            rawText: 'Brak METAR',
          ));
        }
      }
    } catch (e) {
      _error = 'Błąd: $e';
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('METAR IMGW'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
            onPressed: _fetchFromImgw,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        )
            : ListView.separated(
          itemCount: _records.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final r = _records[i];
            return ListTile(
              leading: CircleAvatar(child: Text(r.station)),
              title: Text(
                r.rawText,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              subtitle: Text('Obs: ${r.obsTime}'),
            );
          },
        ),
      ),
    );
  }
}

class _MetarRecord {
  final String station;
  final String rawText;
  final String obsTime;

  _MetarRecord({
    required this.station,
    required this.rawText,
    required this.obsTime,
  });
}
