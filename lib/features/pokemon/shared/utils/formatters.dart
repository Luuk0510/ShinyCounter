String formatDate(DateTime? value) {
  if (value == null) return '--';
  final local = value.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.day)}-${two(local.month)}-${local.year}';
}

String formatDayKey(String key) {
  final parsed = DateTime.tryParse(key);
  if (parsed == null) return key;
  String two(int v) => v.toString().padLeft(2, '0');
  final local = parsed.toLocal();
  return '${two(local.day)}-${two(local.month)}-${local.year}';
}
