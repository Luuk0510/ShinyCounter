import 'dart:io';

void main() {
  final lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) return;
  final filtered = lcov
      .readAsLinesSync()
      .where(
        (line) =>
            // Skip generated l10n
            !line.startsWith('SF:lib/l10n/gen/') &&
            // Skip generated localization files
            !line.startsWith('SF:lib/l10n/app_localizations'),
      )
      .toList();
  lcov.writeAsStringSync(filtered.join('\n'));
}
