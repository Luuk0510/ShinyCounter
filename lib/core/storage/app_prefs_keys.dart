class AppPrefsKeys {
  AppPrefsKeys._();

  static const appLocale = 'app_locale';
  static const themeMode = 'theme_mode';
  static const themeOled = 'theme_oled';
  static const themeSeed = 'theme_seed';

  static const customPokemon = 'custom_pokemon';

  static const Set<String> fixedKeys = {
    appLocale,
    themeMode,
    themeOled,
    themeSeed,
    customPokemon,
  };

  static bool isManagedKey(String key) {
    return fixedKeys.contains(key) ||
        key.startsWith('counter_') ||
        key.startsWith('caught_');
  }
}
