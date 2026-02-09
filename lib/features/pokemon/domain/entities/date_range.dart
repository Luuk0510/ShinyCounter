class DateRange {
  DateRange({required this.start, required this.end}) {
    if (end.isBefore(start)) {
      throw ArgumentError.value(end, 'end', 'must be on or after start');
    }
  }

  final DateTime start;
  final DateTime end;
}
