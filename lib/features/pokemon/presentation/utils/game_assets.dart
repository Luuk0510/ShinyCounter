import 'dart:ui';

import 'package:shiny_counter/core/theme/app_assets.dart';

class GameAssets {
  static const String _defaultLogo = AppAssets.pokeballIcon;

  static const Map<String, String> gameColorsHex = {
    'Legends: ZA': '#7cc890',
    'Scarlet': '#9e2a20',
    'Violet': '#552277',
    'Brilliant Diamond': '#0285c9',
    'Shining Pearl': '#d8b2c3',
    'Legends: Arceus': '#f6cb36',
    'Sword': '#00a1eb',
    'Shield': '#e50058',
    "Let's Go Pikachu": '#f3d924',
    "Let's Go Eevee": '#dfa151',
    'Ultra Sun': '#f7ae00',
    'Ultra Moon': '#1fa7df',
    'Sun': '#f7af00',
    'Moon': '#22bbe7',
    'Omega Ruby': '#b70218',
    'Alpha Sapphire': '#15b7e6',
    'X': '#03549a',
    'Y': '#cf1038',
    'Black 2': '#0085ca',
    'White 2': '#ea181f',
    'Black': '#0e0e0e',
    'White': '#ffffff',
    'HeartGold': '#f8c838',
    'SoulSilver': '#a0c0e8',
    'Platinum': '#d8b800',
    'Diamond': '#1058a8',
    'Pearl': '#e068a0',
    'Emerald': '#08a32b',
    'Ruby': '#f71810',
    'Sapphire': '#15b7e6',
    'FireRed': '#da6434',
    'LeafGreen': '#67df01',
    'Crystal': '#73bac9',
    'Gold': '#998a55',
    'Silver': '#b0b8bf',
  };

  static const Map<String, String> gameLogos = {
    'Legends: ZA': 'assets/games/legendsza.png',
    'Scarlet': 'assets/games/scarlet.png',
    'Violet': 'assets/games/violet.png',
    'Brilliant Diamond': 'assets/games/brilliantdiamond.png',
    'Shining Pearl': 'assets/games/shiningpearl.png',
    'Legends: Arceus': 'assets/games/legendsarceus.png',
    'Sword': 'assets/games/sword.png',
    'Shield': 'assets/games/shield.png',
    "Let's Go Pikachu": 'assets/games/letsgopikachu.png',
    "Let's Go Eevee": 'assets/games/letsgoeevee.png',
    'Ultra Sun': 'assets/games/ultrasun.png',
    'Ultra Moon': 'assets/games/ultramoon.png',
    'Sun': 'assets/games/sun.png',
    'Moon': 'assets/games/moon.png',
    'Omega Ruby': 'assets/games/omegaruby.png',
    'Alpha Sapphire': 'assets/games/alphasapphire.png',
    'X': 'assets/games/x.png',
    'Y': 'assets/games/y.png',
    'Black 2': 'assets/games/black2.png',
    'White 2': 'assets/games/white2.png',
    'Black': 'assets/games/black.png',
    'White': 'assets/games/white.png',
    'HeartGold': 'assets/games/heartgold.png',
    'SoulSilver': 'assets/games/soulsilver.png',
    'Platinum': 'assets/games/platinum.png',
    'Diamond': 'assets/games/diamond.png',
    'Pearl': 'assets/games/pearl.png',
    'Emerald': 'assets/games/emerald.png',
    'Ruby': 'assets/games/ruby.png',
    'Sapphire': 'assets/games/sapphire.png',
    'FireRed': 'assets/games/firered.png',
    'LeafGreen': 'assets/games/leafgreen.png',
    'Crystal': 'assets/games/crystal.png',
    'Gold': 'assets/games/gold.png',
    'Silver': 'assets/games/silver.png',
  };

  static const List<String> games = [
    '',
    'Legends: ZA',
    'Scarlet',
    'Violet',
    'Legends: Arceus',
    'Brilliant Diamond',
    'Shining Pearl',
    'Sword',
    'Shield',
    "Let's Go Pikachu",
    "Let's Go Eevee",
    'Ultra Sun',
    'Ultra Moon',
    'Sun',
    'Moon',
    'Omega Ruby',
    'Alpha Sapphire',
    'X',
    'Y',
    'Black 2',
    'White 2',
    'Black',
    'White',
    'HeartGold',
    'SoulSilver',
    'Platinum',
    'Diamond',
    'Pearl',
    'Emerald',
    'FireRed',
    'LeafGreen',
    'Ruby',
    'Sapphire',
    'Crystal',
    'Gold',
    'Silver',
  ];

  static String logoFor(String? game) => gameLogos[game] ?? _defaultLogo;

  static Color? colorFor(String? game) {
    return _parseHexColor(gameColorsHex[game]);
  }

  static Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceAll('#', '');
    if (normalized.length != 6 && normalized.length != 8) return null;
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) return null;
    if (normalized.length == 6) {
      return Color(0xFF000000 | value);
    }
    return Color(value);
  }
}
