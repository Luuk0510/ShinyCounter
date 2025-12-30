import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/l10n/gen/app_localizations_nl.dart';

void main() {
  test('AppLocalizationsNl exposes expected strings', () {
    final l10n = AppLocalizationsNl();

    expect(l10n.statsTitle, 'Statistieken');
    expect(l10n.statsRangeReset, 'Reset');
    expect(l10n.huntHistoryTitle, 'Telgeschiedenis');
  });
}
