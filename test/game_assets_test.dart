import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/game_assets.dart';

void main() {
  test('provides logos for key games', () {
    expect(GameAssets.logoFor('X'), contains('x.png'));
    expect(GameAssets.logoFor('Y'), contains('y.png'));
    expect(GameAssets.logoFor('Scarlet'), contains('scarlet'));
  });

  test('exposes game list with empty default and known titles', () {
    final games = GameAssets.games;
    expect(games, isNotEmpty);
    expect(games.first, isEmpty); // default placeholder
    expect(
      games,
      containsAll(['Scarlet', 'Violet', 'HeartGold', 'SoulSilver']),
    );
  });

  test('falls back to default logo for unknown game', () {
    expect(GameAssets.logoFor('Unknown Title'), contains('pokeball_icon'));
    expect(GameAssets.logoFor(null), contains('pokeball_icon'));
  });
}
