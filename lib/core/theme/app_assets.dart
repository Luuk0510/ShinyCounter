class AppAssets {
  AppAssets._();

  static const appIcon = 'assets/icon/app_icon.png';
  static const pokeballIcon = 'assets/icon/pokeball_icon.png';

  /// Convenience list for iterating all known assets (useful in tests/tools).
  static List<String> all() => const [appIcon, pokeballIcon];
}
