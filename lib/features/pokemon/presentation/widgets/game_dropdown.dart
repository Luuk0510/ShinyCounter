import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/game_assets.dart';

class GameDropdown extends StatelessWidget {
  const GameDropdown({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const games = GameAssets.games;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gameLabel,
          style: AppTypography.sectionTitle.copyWith(
            color: colors.onSurfaceVariant,
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          onChanged: (val) => onChanged(val?.isEmpty == true ? null : val),
          hint: Text(l10n.gameHint),
        ),
      ],
    );
  }

  static String logoFor(String? game) => GameAssets.logoFor(game);
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
    final textStyle = dense
        ? AppTypography.button
        : AppTypography.sectionTitle.copyWith(fontWeight: FontWeight.w700);
    return Row(
      children: [
        GameLogo(game: game, size: dense ? AppSpacing.xl : AppSpacing.xxl),
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
  const GameLogo({super.key, required this.game, this.size = AppSpacing.xxl});

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
        errorBuilder: (_, error, stackTrace) => Center(
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
