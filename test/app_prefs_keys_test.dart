import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/core/storage/app_prefs_keys.dart';

void main() {
  test('AppPrefsKeys exposes stable keys', () {
    expect(AppPrefsKeys.appLocale, 'app_locale');
    expect(AppPrefsKeys.themeMode, 'theme_mode');
    expect(AppPrefsKeys.themeOled, 'theme_oled');
    expect(AppPrefsKeys.customPokemon, 'custom_pokemon');
  });
}
