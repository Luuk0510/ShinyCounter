import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/game_dropdown.dart';

class HuntInfoCard extends StatelessWidget {
  const HuntInfoCard({
    super.key,
    required this.colors,
    required this.startedAt,
    required this.caughtAt,
    required this.caughtGame,
    required this.formatter,
    required this.onSelectGame,
    required this.onGameChanged,
  });

  final ColorScheme colors;
  final DateTime? startedAt;
  final DateTime? caughtAt;
  final String? caughtGame;
  final String Function(DateTime?) formatter;
  final VoidCallback onSelectGame;
  final ValueChanged<String?> onGameChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labelStyle = AppTypography.button.copyWith(
      color: colors.onSurfaceVariant,
    );
    final valueStyle = AppTypography.sectionTitle.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w800,
    );
    final cardColor = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HuntCell(
                label: l10n.huntStart,
                value: formatter(startedAt),
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
              const SizedBox(width: AppSpacing.md),
              _HuntCell(
                label: l10n.huntCatch,
                value: formatter(caughtAt),
                labelStyle: labelStyle,
                valueStyle: valueStyle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: (caughtGame == null || caughtGame!.isEmpty)
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: DropdownButtonFormField<String?>(
                      initialValue: null,
                      isExpanded: true,
                      items: GameDropdown.games
                          .map(
                            (g) => DropdownMenuItem<String?>(
                              value: g.isEmpty ? null : g,
                              child: Row(
                                children: [
                                  GameLogo(game: g, size: AppSpacing.xxl),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      g.isEmpty ? l10n.selectGameHint : g,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.sectionTitle.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.sm),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onChanged: onGameChanged,
                      hint: Text(l10n.selectGameHint),
                    ),
                  )
                : InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    onTap: onSelectGame,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GameLogo(game: caughtGame!, size: AppSpacing.xxl),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.huntGame(caughtGame!),
                            textAlign: TextAlign.center,
                            style: AppTypography.sectionTitle.copyWith(
                              color: colors.onSurface,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HuntCell extends StatelessWidget {
  const _HuntCell({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: valueStyle),
      ],
    );
  }
}
