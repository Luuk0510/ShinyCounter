import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/game_assets.dart';

void main() {
  test('provides logos for key games', () {
    expect(GameAssets.logoFor('X'), contains('x.png'));
    expect(GameAssets.logoFor('Y'), contains('y.png'));
    expect(GameAssets.logoFor('Scarlet'), contains('scarlet'));
  });
}
