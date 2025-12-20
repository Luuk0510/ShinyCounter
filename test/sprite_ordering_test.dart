import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_ordering.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

void main() {
  group('sprite ordering', () {
    test('mega sorts before gmax (detail)', () {
      final base = ParsedSprite(
        dex: '0001',
        form: 'base',
        gender: 'm',
        shiny: true,
        path: 'a.png',
      );
      final mega = ParsedSprite(
        dex: '0001',
        form: 'mega-x',
        gender: 'm',
        shiny: true,
        path: 'b.png',
      );
      final gmax = ParsedSprite(
        dex: '0001',
        form: '001-gmax',
        gender: 'm',
        shiny: true,
        path: 'c.png',
      );

      final list = [gmax, mega, base]..sort(compareSpritesForDetail);
      expect(list, [base, mega, gmax]);
    });

    test('isMegaOrGmaxForm detects variants', () {
      expect(isMegaOrGmaxForm('mega-x'), isTrue);
      expect(isMegaOrGmaxForm('001-gmax'), isTrue);
      expect(isMegaOrGmaxForm('alola'), isFalse);
    });

    test('spriteFormRankForDetail assigns base before mega/gmax', () {
      expect(spriteFormRankForDetail('base'), 0);
      expect(spriteFormRankForDetail('mega-x'), 1);
      expect(spriteFormRankForDetail('gmax'), 2);
    });

    test('compareSpritesForDetail breaks ties by gender then path', () {
      final male = ParsedSprite(
        dex: '0001',
        form: 'base',
        gender: 'm',
        shiny: true,
        path: 'a.png',
      );
      final female = ParsedSprite(
        dex: '0001',
        form: 'base',
        gender: 'f',
        shiny: true,
        path: 'b.png',
      );
      final femaleAlt = ParsedSprite(
        dex: '0001',
        form: 'base',
        gender: 'f',
        shiny: true,
        path: 'a.png',
      );

      final list = [female, male, femaleAlt]..sort(compareSpritesForDetail);
      expect(list.first, femaleAlt);
      expect(list[1], female);
      expect(list.last, male);
    });
  });
}
