import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/selectable_row.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({
    super.key,
    required this.selectedLocale,
    required this.onLocaleChanged,
  });

  final Locale? selectedLocale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsLanguage,
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        _ThemeOption(
          label: l10n.languageEnglish,
          selected: selectedLocale?.languageCode == 'en',
          onTap: () => onLocaleChanged(const Locale('en')),
        ),
        _ThemeOption(
          label: l10n.languageDutch,
          selected: selectedLocale?.languageCode == 'nl',
          onTap: () => onLocaleChanged(const Locale('nl')),
        ),
      ],
    );
  }
}

class ThemeSection extends StatelessWidget {
  const ThemeSection({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final ThemeMode mode;
  final void Function(ThemeMode mode, {bool? useOled}) onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final useOledDark = context.watch<ThemeNotifier>().useOledDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsTitle,
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        _ThemeOption(
          label: l10n.settingsSystem,
          selected: mode == ThemeMode.system,
          onTap: () => onModeChanged(ThemeMode.system),
        ),
        _ThemeOption(
          label: l10n.settingsLight,
          selected: mode == ThemeMode.light,
          onTap: () => onModeChanged(ThemeMode.light),
        ),
        _ThemeOption(
          label: l10n.settingsDark,
          selected: mode == ThemeMode.dark && !useOledDark,
          onTap: () => onModeChanged(ThemeMode.dark, useOled: false),
        ),
        _ThemeOption(
          label: l10n.settingsOled,
          selected: mode == ThemeMode.dark && useOledDark,
          onTap: () => onModeChanged(ThemeMode.dark, useOled: true),
        ),
      ],
    );
  }
}

class AccentColorSection extends StatelessWidget {
  const AccentColorSection({
    super.key,
    required this.seedColor,
    required this.onSeedColorChanged,
  });

  final Color? seedColor;
  final ValueChanged<Color?> onSeedColorChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsAccentColor,
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._seedOptions(l10n).map((option) {
          final selected = option.color == null
              ? seedColor == null
              : seedColor?.toARGB32() == option.color!.toARGB32();
          return _SeedOptionRow(
            label: option.label,
            swatch: option.swatch,
            selected: selected,
            onTap: () => onSeedColorChanged(option.color),
          );
        }),
      ],
    );
  }
}

class DataSection extends StatelessWidget {
  const DataSection({
    super.key,
    required this.onExport,
    required this.onImport,
  });

  final VoidCallback onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsDataTitle,
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        SettingsActionRow(
          icon: Icons.upload_rounded,
          label: l10n.settingsExportJson,
          onTap: onExport,
        ),
        const SizedBox(height: AppSpacing.xs),
        SettingsActionRow(
          icon: Icons.download_rounded,
          label: l10n.settingsImportJson,
          onTap: onImport,
        ),
      ],
    );
  }
}

class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SelectableRow(
      selected: false,
      onTap: onTap,
      selectedColor: AppButtonPalette.primaryFill(colors),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeedOption {
  const _SeedOption({required this.label, required this.color, this.swatch});

  final String label;
  final Color? color;
  final Color? swatch;
}

List<_SeedOption> _seedOptions(AppLocalizations l10n) {
  return [
    _SeedOption(label: l10n.colorDefault, color: null, swatch: AppColors.seed),
    _SeedOption(
      label: l10n.colorRed,
      color: AppSeedColors.red,
      swatch: AppSeedColors.red,
    ),
    _SeedOption(
      label: l10n.colorOrange,
      color: AppSeedColors.orange,
      swatch: AppSeedColors.orange,
    ),
    _SeedOption(
      label: l10n.colorYellow,
      color: AppSeedColors.yellow,
      swatch: AppSeedColors.yellow,
    ),
    _SeedOption(
      label: l10n.colorGreen,
      color: AppSeedColors.green,
      swatch: AppSeedColors.green,
    ),
    _SeedOption(
      label: l10n.colorTeal,
      color: AppSeedColors.teal,
      swatch: AppSeedColors.teal,
    ),
    _SeedOption(
      label: l10n.colorBlue,
      color: AppSeedColors.blue,
      swatch: AppSeedColors.blue,
    ),
    _SeedOption(
      label: l10n.colorDarkBlue,
      color: AppSeedColors.darkBlue,
      swatch: AppSeedColors.darkBlue,
    ),
    _SeedOption(
      label: l10n.colorPurple,
      color: AppSeedColors.purple,
      swatch: AppSeedColors.purple,
    ),
    _SeedOption(
      label: l10n.colorPink,
      color: AppSeedColors.pink,
      swatch: AppSeedColors.pink,
    ),
  ];
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highlightColor = AppButtonPalette.primaryHighlight(colors);
    final checkmarkColor = context.watch<ThemeNotifier>().seedColor;
    return SelectableRow(
      selected: selected,
      onTap: onTap,
      selectedColor: highlightColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? highlightColor : colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SelectableCheckmark(
            selected: selected,
            selectedColor: checkmarkColor,
            unselectedIcon: Icons.circle_outlined,
            unselectedColor: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _SeedOptionRow extends StatelessWidget {
  const _SeedOptionRow({
    required this.label,
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color? swatch;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rowColor = swatch ?? AppButtonPalette.primaryAccent(colors);
    final highlightColor = AppButtonPalette.highlightFor(rowColor);
    final checkmarkColor = swatch ?? AppButtonPalette.primaryFill(colors);
    return SelectableRow(
      selected: selected,
      onTap: onTap,
      selectedColor: rowColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.seedSwatch,
            height: AppSizes.seedSwatch,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: swatch ?? AppButtonPalette.primaryFill(colors),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? highlightColor : colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SelectableCheckmark(
            selected: selected,
            selectedColor: checkmarkColor,
            unselectedIcon: Icons.circle_outlined,
            unselectedColor: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
