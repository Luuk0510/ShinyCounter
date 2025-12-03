import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late ThemeMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = context.read<ThemeNotifier>().mode;
  }

  void _setMode(ThemeMode mode, {bool? useOled}) {
    final notifier = context.read<ThemeNotifier>();
    notifier.setMode(mode, useOledDark: useOled ?? notifier.useOledDark);
    setState(() => _mode = notifier.mode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.settingsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
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
