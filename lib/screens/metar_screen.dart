// lib/screens/metar_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MetarScreen extends StatefulWidget {
  const MetarScreen({Key? key}) : super(key: key);

  @override
  State<MetarScreen> createState() => _MetarScreenState();
}

class _MetarScreenState extends State<MetarScreen> {
  final List<String> _stations = [
    'EPRA', 'EPDE', 'EPLB', 'EPMM', 'EPLK', 'EPKK'
  ];
  bool _loading = true;
  String? _error;
  final List<_MetarRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _fetchAllMetar();
  }

  Future<void> _fetchAllMetar() async {
    setState(() {
      _loading = true;
      _error = null;
      _records.clear();
    });

    // 1) pobierz JSON z ADDS
    final addsUrl = Uri.https(
      'aviationweather.gov',
      '/adds/dataserver_current/httpparam',
      {
        'dataSource'    : 'metars',
        'requestType'   : 'retrieve',
        'format'        : 'JSON',
        'stations'      : _stations.join(','),
        'hoursBeforeNow': '3',
      },
    ).toString();

    final jsonUrl = kIsWeb
        ? 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(addsUrl)}'
        : addsUrl;

    Map<String, dynamic>? jsonData;
    try {
      final resp = await http.get(Uri.parse(jsonUrl));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }
      final decoded = json.decode(resp.body) as Map<String, dynamic>;
      final dataSec = decoded['data'] as Map<String, dynamic>?;
      final metarList = dataSec?['METAR'] as List<dynamic>?;
      jsonData = <String, dynamic>{
        for (var e in metarList ?? [])
          (e['station_id'] as String): e
      };
    } catch (e) {
      // jeśli błąd ADDS – oznaczimy jsonData = {}
      jsonData = {};
    }

    // 2) dla każdej stacji: najpierw z ADDS, inaczej fallback NOAA
    for (final st in _stations) {
      final rec = jsonData![st] as Map<String, dynamic>?;
      if (rec != null) {
        _records.add(_MetarRecord(
          station: st,
          rawText: rec['raw_text'] as String? ?? '—',
          obsTime: rec['observation_time'] as String? ?? '',
        ));
      } else {
        _records.add(await _fetchNoaa(st));
      }
    }

    setState(() {
      _loading = false;
    });
  }

  // fallback dla militariów / braków: NOAA TGFTP .TXT
  Future<_MetarRecord> _fetchNoaa(String st) async {
    final txtUrl = 'https://tgftp.nws.noaa.gov/data/observations/metar/stations/$st.TXT';
    final fetchUrl = kIsWeb
        ? 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(txtUrl)}'
        : txtUrl;

    try {
      final resp = await http.get(Uri.parse(fetchUrl)).timeout(const Duration(seconds: 5));
      if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
      final lines = resp.body
          .split(RegExp(r'[\r\n]+'))
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.length >= 2 && lines[1].startsWith(st)) {
        return _MetarRecord(station: st, rawText: lines[1], obsTime: lines[0]);
      } else if (lines.isNotEmpty && lines[0].startsWith(st)) {
        return _MetarRecord(station: st, rawText: lines[0], obsTime: '');
      } else {
        return _MetarRecord(station: st, rawText: 'Brak METAR', obsTime: '');
      }
    } on TimeoutException {
      return _MetarRecord(station: st, rawText: 'Błąd: timeout', obsTime: '');
    } catch (e) {
      return _MetarRecord(station: st, rawText: 'Błąd: $e', obsTime: '');
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('METAR zbiorcze'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
            onPressed: _fetchAllMetar,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
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
              subtitle: r.obsTime.isNotEmpty
                  ? Text('Obs: ${r.obsTime}')
                  : null,
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
