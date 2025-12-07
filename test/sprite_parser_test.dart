import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

void main() {
  group('SpriteParser', () {
    test('parses new naming convention', () {
      final parsed = SpriteParser.parse('0001_base_std_none_mf_s.png');
      expect(parsed, isNotNull);
      expect(parsed!.dex, '0001');
      expect(parsed.form, 'base_std_none');
      expect(parsed.gender, 'mf');
      expect(parsed.shiny, isTrue);
      expect(parsed.path, '0001_base_std_none_mf_s.png');
    });

    test('parses legacy naming convention', () {
      final parsed =
          SpriteParser.parse('poke_capture_0006_000_mf_n_00000000_f_r.png');
      expect(parsed, isNotNull);
      expect(parsed!.dex, '0006');
      expect(parsed.form, '000');
      expect(parsed.gender, 'mf');
      expect(parsed.shiny, isTrue);
    });

    test('returns null for unknown pattern', () {
      final parsed = SpriteParser.parse('invalid_file.png');
      expect(parsed, isNull);
    });
  });
}
