import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/theme/app_assets.dart';

void main() {
  test('app asset paths stay consistent', () {
    expect(AppAssets.appIcon, 'assets/icon/app_icon.png');
    expect(AppAssets.pokeballIcon, 'assets/icon/pokeball_icon.png');
    expect(
      AppAssets.all(),
      containsAll([AppAssets.appIcon, AppAssets.pokeballIcon]),
    );
  });
}
