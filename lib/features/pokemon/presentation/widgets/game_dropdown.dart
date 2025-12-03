import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class GameDropdown extends StatelessWidget {
  const GameDropdown({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const games = [
    '',
    'Legends: ZA',
    'Scarlet',
    'Violet',
    'Brilliant Diamond',
    'Shining Pearl',
    'Legends: Arceus',
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
    'Ruby',
    'Sapphire',
    'FireRed',
    'LeafGreen',
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
          items: games
              .map(
                (g) => DropdownMenuItem<String?>(
                  value: g.isEmpty ? null : g,
                  child: Text(g.isEmpty ? l10n.gameNone : g),
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
}
