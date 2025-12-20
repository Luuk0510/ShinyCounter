import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/storage/app_prefs_keys.dart';

void main() {
  test('app prefs keys stay stable', () {
    expect(AppPrefsKeys.appLocale, 'app_locale');
    expect(AppPrefsKeys.themeMode, 'theme_mode');
    expect(AppPrefsKeys.themeOled, 'theme_oled');
    expect(AppPrefsKeys.customPokemon, 'custom_pokemon');
  });
}
