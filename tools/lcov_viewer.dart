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

void renderTree(Node node, StringBuffer buffer, {bool forceOpen = false}) {
  final children = node.children.values.toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  buffer.writeln('<ul>');
  for (final child in children) {
    buffer.writeln('<li>');
    final label = htmlEscape.convert(child.name);
    final pct = child.pct.toStringAsFixed(1);
    buffer.writeln(
      '<details ${forceOpen || child.children.isEmpty ? 'open' : ''}>'
      '<summary><span class="name">$label</span>'
      '<span class="pct ${pctClass(child)}">$pct%</span>'
      '<span class="counts">${child.hit}/${child.found}</span>'
      '</summary>',
    );
    if (child.children.isNotEmpty) {
      renderTree(child, buffer, forceOpen: forceOpen);
    }
    buffer.writeln('</details></li>');
  }
  buffer.writeln('</ul>');
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
    final parts = rec.file
        .split(RegExp(r'[\\/]'))
        .where((p) => p.isNotEmpty)
        .toList();
    root.add(parts, rec);
  }

  String headerColor(double pct) {
    // Gradient from red (0) to yellow (50) to green (100).
    int lerp(int a, int b, double t) => (a + ((b - a) * t)).round();
    String toHex(int value) => value.toRadixString(16).padLeft(2, '0');

    if (pct <= 50) {
      final t = pct / 50;
      final r = lerp(0xC0, 0xE6, t);
      final g = lerp(0x39, 0x7E, t);
      final b = lerp(0x2B, 0x22, t);
      return '#${toHex(r)}${toHex(g)}${toHex(b)}';
    }
    final t = (pct - 50) / 50;
    final r = lerp(0xE6, 0x2E, t);
    final g = lerp(0x7E, 0x7D, t);
    final b = lerp(0x22, 0x32, t);
    return '#${toHex(r)}${toHex(g)}${toHex(b)}';
  }

  final buffer = StringBuffer()
    ..writeln('<!doctype html><html><head><meta charset="utf-8">')
    ..writeln(
      '<style>'
      'body{font-family:Arial,sans-serif;margin:16px;background:#f8f9fb;display:flex;justify-content:center;}'
      '.container{max-width:700px;width:100%;}'
      'details{margin:4px 0;}'
      'summary{cursor:pointer;display:flex;gap:12px;align-items:center;}'
      'ul{list-style:none;padding-left:18px;margin:6px 0;}'
      'li{margin:2px 0;}'
      '.name{flex:1;font-weight:600;}'
      '.pct{min-width:70px;text-align:right;font-weight:700;}'
      '.counts{min-width:80px;text-align:right;color:#666;}'
      '.good{color:#2e7d32;}'
      '.warn{color:#e67e22;}'
      '.bad{color:#c0392b;}'
      'details>summary::-webkit-details-marker{display:none;}'
      'details>summary:before{content:"\\25BC";display:inline-block;transform:rotate(-90deg);transition:transform .15s ease;margin-right:8px;color:#888;}'
      'details[open]>summary:before{transform:rotate(0deg);}'
      '.header{color:white;padding:10px 12px;border-radius:8px;margin-bottom:12px;font-weight:700;}'
      '.legend{display:flex;gap:16px;justify-content:flex-end;color:#888;font-weight:700;padding:4px 0;}'
      '.legend span{min-width:90px;text-align:right;}'
      '</style>',
    )
    ..writeln('</head><body><div class="container">')
    ..writeln(
      '<div class="header" style="background:${headerColor(root.pct)};">'
      'Coverage: ${root.pct.toStringAsFixed(1)}% (${root.hit}/${root.found})</div>',
    )
    ..writeln(
      '<div class="legend"><span>Coverage</span><span>Lines</span></div>',
    )
    ..writeln(
      '<details open><summary><span class="name">All Files</span>'
      '<span class="pct ${pctClass(root)}">${root.pct.toStringAsFixed(1)}%</span>'
      '<span class="counts">${root.hit}/${root.found}</span></summary>',
    );
  renderTree(root, buffer, forceOpen: true);
  buffer
    ..writeln('</details>')
    ..writeln('</div></body></html>');

  stdout.write(buffer.toString());
}
