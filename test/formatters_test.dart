import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/formatters.dart';

void main() {
  group('formatters', () {
    test('formatDate handles null', () {
      expect(formatDate(null), '--');
    });

    test('formatDate returns dd-mm-yyyy', () {
      final date = DateTime.utc(2024, 5, 3);
      expect(formatDate(date), '03-05-2024');
    });

    test('formatDayKey parses iso keys', () {
      final key = '2024-05-03';
      expect(formatDayKey(key), '03-05-2024');
    });

    test('formatDayKey returns original on invalid', () {
      expect(formatDayKey('not-a-date'), 'not-a-date');
    });
  });
}
