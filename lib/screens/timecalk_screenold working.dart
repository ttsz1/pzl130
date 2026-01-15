import 'package:flutter/material.dart';

class TimeCalkScreen extends StatefulWidget {
  const TimeCalkScreen({super.key});

  @override
  State<TimeCalkScreen> createState() => _TimeCalkScreenState();
}

class _TimeCalkScreenState extends State<TimeCalkScreen> {
  final controller = TextEditingController();
  String result = '';
  List<String> history = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleKey(String v) {
    final text = controller.text;
    if (v == 'C') {
      controller.text = '';
    } else if (v == '←') {
      if (text.isNotEmpty) {
        controller.text = text.substring(0, text.length - 1);
      }
    } else {
      controller.text = text + v;
    }
    setState(() {});
  }

  int _parseComponent(String token) {
    token = token.replaceAll(',', ':').replaceAll('.', ':').trim();

    if (token.endsWith('h')) {
      final h = double.tryParse(token.substring(0, token.length - 1)) ?? 0.0;
      return (h * 60).round();
    }
    if (token.endsWith('m')) {
      return int.tryParse(token.substring(0, token.length - 1)) ?? 0;
    }
    if (token.contains(':')) {
      final p = token.split(':');
      final h = int.tryParse(p[0]) ?? 0;
      final m = int.tryParse(p.length > 1 ? p[1] : '0') ?? 0;
      return h * 60 + m;
    }
    return int.tryParse(token) ?? 0;
  }

  String _format(int tot) {
    final h = tot ~/ 60;
    final m = tot % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  void _calculate() {
    final expr = controller.text.replaceAll(' ', '');
    final parts = RegExp(r'([^\+\-\*/]+|[\+\-\*/])')
        .allMatches(expr)
        .map((m) => m.group(0)!)
        .toList();

    int? acc;
    String? op;
    final disp = <String>[];

    try {
      for (var t in parts) {
        if (['+', '-', '*', '/'].contains(t)) {
          op = t;
          disp.add(t);
        } else {
          final val = _parseComponent(t);
          disp.add(_format(val));
          if (acc == null) {
            acc = val;
          } else {
            switch (op) {
              case '+':
                acc += val;
                break;
              case '-':
                acc -= val;
                break;
              case '*':
                acc *= val;
                break;
              case '/':
                acc ~/= (val == 0 ? 1 : val);
                break;
            }
          }
          op = null;
        }
      }

      if (acc != null) {
        final out = _format(acc);
        setState(() {
          result = out;
          history.insert(0, '${disp.join(' ')} = $out');
          if (history.length > 5) history.removeLast();
        });
      }
    } catch (_) {
      setState(() => result = 'Błąd');
    }
  }

  void _clearHistory() {
    setState(() {
      history.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historia wyczyszczona')),
    );
  }

  Widget _buildKey(String label) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _handleKey(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildKeypad() {
    final rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['0', ':', 'h', 'm', '←'],
      ['+', '-', '*', '/', 'C'],
    ];
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: 8,
            children: row.map(_buildKey).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeCalk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Wyczyść historię',
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Wyrażenie
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wyrażenie:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'np. 5h+30m+1:20',
              ),
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 16),
            // Klawiatura
            _buildKeypad(),

            const SizedBox(height: 16),
            // Oblicz
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Oblicz', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),

            const SizedBox(height: 24),
            // Wynik
            if (result.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Wynik:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Historia
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Historia (ostatnie 5):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('Brak historii'))
                  : ListView.builder(
                itemCount: history.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(history[i], style: const TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
