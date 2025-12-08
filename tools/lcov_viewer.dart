import 'dart:convert';
import 'dart:io';

class Record {
  Record(this.file, this.hit, this.found);
  final String file;
  final int hit;
  final int found;
}

class Node {
  Node(this.name, {this.isFile = false});

  final String name;
  final bool isFile;
  int hit = 0;
  int found = 0;
  final Map<String, Node> children = {};

  double get pct => found == 0 ? 100 : hit / found * 100;

  void add(List<String> parts, Record record) {
    if (parts.isEmpty) {
      hit = record.hit;
      found = record.found;
      return;
    }
    final head = parts.first;
    final tail = parts.skip(1).toList();
    final child = children.putIfAbsent(
      head,
      () => Node(head, isFile: tail.isEmpty),
    );
    child.add(tail, record);
    _recompute();
  }

  void _recompute() {
    hit = children.values.fold(0, (sum, c) => sum + c.hit);
    found = children.values.fold(0, (sum, c) => sum + c.found);
  }
}

String pctClass(Node n) {
  if (n.pct >= 90) return 'good';
  if (n.pct >= 60) return 'warn';
  return 'bad';
}

void renderTable(Node node, StringBuffer buffer, {String prefix = ''}) {
  final name = node.name.isEmpty ? 'All Files' : node.name;
  final path = prefix.isEmpty ? name : '$prefix/$name';
  buffer.writeln(
    '<tr>'
    '<td>${htmlEscape.convert(path)}</td>'
    '<td class="${pctClass(node)}">${node.pct.toStringAsFixed(1)}%</td>'
    '<td>${node.hit}</td>'
    '<td>${node.found}</td>'
    '</tr>',
  );
  final children = node.children.values.toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  for (final child in children) {
    renderTable(child, buffer, prefix: path == 'All Files' ? child.name : path);
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart tools/lcov_viewer.dart coverage/lcov.info > coverage/coverage.html',
    );
    exit(1);
  }

  final lines = await File(args.first).readAsLines();
  final records = <Record>[];
  String? file;
  int hit = 0, found = 0;
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      file = line.substring(3);
      hit = 0;
      found = 0;
    } else if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        final hits = int.tryParse(parts[1]) ?? 0;
        if (hits > 0) hit++;
        found++;
      }
    } else if (line == 'end_of_record' && file != null) {
      records.add(Record(file, hit, found));
      file = null;
    }
  }

  final root = Node('');
  for (final rec in records) {
    final parts = rec.file.split(RegExp(r'[\\/]')).where((p) => p.isNotEmpty).toList();
    root.add(parts, rec);
  }

  final buffer = StringBuffer()
    ..writeln('<!doctype html><html><head><meta charset="utf-8">')
    ..writeln('<style>'
        'body{font-family:Arial,sans-serif;margin:16px;background:#f8f9fb;}'
        'table{border-collapse:collapse;width:100%;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,0.1);}'
        'th,td{padding:8px 10px;border-bottom:1px solid #e0e0e0;}'
        'th{text-align:left;background:#f0f0f5;font-weight:700;}'
        '.good{color:#2e7d32;}'
        '.warn{color:#e67e22;}'
        '.bad{color:#c0392b;}'
        '.header{background:#e6519a;color:white;padding:10px 12px;border-radius:8px;margin-bottom:12px;font-weight:700;}'
        '</style>')
    ..writeln('</head><body>')
    ..writeln(
      '<div class="header">Coverage: ${root.pct.toStringAsFixed(1)}% (${root.hit}/${root.found})</div>',
    )
    ..writeln('<table><tr><th>Path</th><th>Line %</th><th>Covered</th><th>Total</th></tr>');
  renderTable(root, buffer);
  buffer
    ..writeln('</table>')
    ..writeln('</body></html>');

  stdout.write(buffer.toString());
}
