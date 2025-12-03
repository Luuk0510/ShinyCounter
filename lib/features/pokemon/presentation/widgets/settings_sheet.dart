import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late ThemeMode _mode;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _mode = context.read<ThemeNotifier>().mode;
    _locale = context.read<LocaleNotifier>().locale;
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(
        l10n.tooltipSettings,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsLanguage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
              selected: _mode == ThemeMode.dark &&
                  !context.watch<ThemeNotifier>().useOledDark,
              onTap: () => _setMode(ThemeMode.dark, useOled: false),
            ),
            _ThemeOption(
              label: l10n.settingsOled,
              selected: _mode == ThemeMode.dark &&
                  context.watch<ThemeNotifier>().useOledDark,
              onTap: () => _setMode(ThemeMode.dark, useOled: true),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text(
              l10n.cancel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? colors.primary : colors.onSurface,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: colors.primary)
          : Icon(Icons.circle_outlined, color: colors.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
