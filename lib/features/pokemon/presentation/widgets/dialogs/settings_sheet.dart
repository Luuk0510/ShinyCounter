import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/selectable_row.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late ThemeMode _mode;
  Locale? _locale;
  Color? _seedColor;

  @override
  void initState() {
    super.initState();
    _mode = context.read<ThemeNotifier>().mode;
    _locale = context.read<LocaleNotifier>().locale;
    final theme = context.read<ThemeNotifier>();
    _seedColor = theme.usesDefaultSeed ? null : theme.seedColor;
  }

  void _setMode(ThemeMode mode, {bool? useOled}) {
    final notifier = context.read<ThemeNotifier>();
    notifier.setMode(mode, useOledDark: useOled ?? notifier.useOledDark);
    setState(() => _mode = notifier.mode);
  }

  void _setLocale(Locale locale) {
    context.read<LocaleNotifier>().setLocale(locale);
    setState(() => _locale = locale);
  }

  void _setSeedColor(Color? color) {
    context.read<ThemeNotifier>().setSeedColor(color);
    setState(() => _seedColor = color);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        l10n.tooltipSettings,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsLanguage,
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            _ThemeOption(
              label: l10n.languageEnglish,
              selected: _locale?.languageCode == 'en',
              onTap: () => _setLocale(const Locale('en')),
            ),
            _ThemeOption(
              label: l10n.languageDutch,
              selected: _locale?.languageCode == 'nl',
              onTap: () => _setLocale(const Locale('nl')),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.settingsTitle,
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            _ThemeOption(
              label: l10n.settingsSystem,
              selected: _mode == ThemeMode.system,
              onTap: () => _setMode(ThemeMode.system),
            ),
            _ThemeOption(
              label: l10n.settingsLight,
              selected: _mode == ThemeMode.light,
              onTap: () => _setMode(ThemeMode.light),
            ),
            _ThemeOption(
              label: l10n.settingsDark,
              selected:
                  _mode == ThemeMode.dark &&
                  !context.watch<ThemeNotifier>().useOledDark,
              onTap: () => _setMode(ThemeMode.dark, useOled: false),
            ),
            _ThemeOption(
              label: l10n.settingsOled,
              selected:
                  _mode == ThemeMode.dark &&
                  context.watch<ThemeNotifier>().useOledDark,
              onTap: () => _setMode(ThemeMode.dark, useOled: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.settingsAccentColor,
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._seedOptions(l10n).map((option) {
              final selected = option.color == null
                  ? _seedColor == null
                  : _seedColor?.value == option.color!.value;
              return _SeedOptionRow(
                label: option.label,
                swatch: option.swatch,
                selected: selected,
                onTap: () => _setSeedColor(option.color),
              );
            }),
          ],
        ),
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppButtonStyles.primaryOutline(
                  colors,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.settingsActionPaddingH,
                    vertical: AppSizes.settingsActionPaddingV,
                  ),
                  useLighter: true,
                ),
                child: Text(
                  l10n.cancel,
                  style: AppTypography.button.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'v2.2.0',
              style: AppTypography.button.copyWith(
                fontSize: AppSizes.overlayLabelSize,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
    final selectedColor = AppButtonPalette.primaryFill(colors);
    return SelectableRow(
      selected: selected,
      onTap: onTap,
      selectedColor: selectedColor,
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
                color: selected ? selectedColor : colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SelectableCheckmark(
            selected: selected,
            selectedColor: selectedColor,
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
    final selectedColor = swatch ?? AppButtonPalette.primaryAccent(colors);
    return SelectableRow(
      selected: selected,
      onTap: onTap,
      selectedColor: selectedColor,
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
                color: selected ? selectedColor : colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SelectableCheckmark(
            selected: selected,
            selectedColor: selectedColor,
            unselectedIcon: Icons.circle_outlined,
            unselectedColor: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
