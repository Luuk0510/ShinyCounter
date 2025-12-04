import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class GameDropdown extends StatelessWidget {
  const GameDropdown({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const String _defaultLogo = 'assets/icon/pokeball_icon.png';
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
    'X': 'assets/games/X.png',
    'Y': 'assets/games/Y.png',
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

  static const games = [
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gameLabel,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String?>(
          initialValue: value?.isEmpty == true ? null : value,
          isExpanded: true,
          selectedItemBuilder: (context) => games
              .map(
                (g) => _GameTile(
                  game: g,
                  label: g.isEmpty ? l10n.gameNone : g,
                  showHintLabel: g.isEmpty,
                  dense: true,
                ),
              )
              .toList(),
          items: games
              .map(
                (g) => DropdownMenuItem<String?>(
                  value: g.isEmpty ? null : g,
                  child: _GameTile(
                    game: g,
                    label: g.isEmpty ? l10n.gameNone : g,
                    showHintLabel: g.isEmpty,
                  ),
                ),
              )
              .toList(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (val) => onChanged(val?.isEmpty == true ? null : val),
          hint: Text(l10n.gameHint),
        ),
      ],
    );
  }

  static String logoFor(String? game) {
    if (game == null || game.isEmpty) return _defaultLogo;
    return gameLogos[game] ?? _defaultLogo;
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.game,
    required this.label,
    this.showHintLabel = false,
    this.dense = false,
  });

  final String game;
  final String label;
  final bool showHintLabel;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: dense ? 14 : 16,
      fontWeight: FontWeight.w600,
    );
    return Row(
      children: [
        GameLogo(game: game, size: dense ? 24 : 28),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(
              color: showHintLabel
                  ? Theme.of(context).hintColor
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class GameLogo extends StatelessWidget {
  const GameLogo({super.key, required this.game, this.size = 28});

  final String game;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = game.isEmpty ? '?' : game.characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primaryContainer.withValues(alpha: 0.8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        GameDropdown.logoFor(game),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: size * 0.45,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
