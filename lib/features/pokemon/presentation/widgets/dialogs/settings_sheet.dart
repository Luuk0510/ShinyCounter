import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/storage/app_backup_service.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/selectable_row.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/dialogs.dart';
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
  final AppBackupService _backupService = AppBackupService();

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

  Future<void> _exportBackup() async {
    final l10n = context.l10n;
    try {
      final content = await _backupService.exportJson();
      if (!mounted) return;
      final bytes = Uint8List.fromList(utf8.encode(content));
      final now = DateTime.now();
      final filename =
          'shiny_counter_backup_${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      final path = await FileSaver.instance.saveAs(
        name: filename.replaceAll('.json', ''),
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );
      if (path == null || path.isEmpty) return;
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsExportSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsExportFailed)));
    }
  }

  Future<void> _importBackup() async {
    final l10n = context.l10n;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      final path = file.path;
      if (bytes == null && path == null) return;
      if (!mounted) return;
      final confirmed = await showScaledDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            l10n.settingsImportConfirmTitle,
            textAlign: TextAlign.center,
            style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
          ),
          content: Text(
            l10n.settingsImportConfirmMessage,
            textAlign: TextAlign.center,
            style: AppTypography.button.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: AppButtonStyles.primaryOutline(
                Theme.of(context).colorScheme,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
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
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: AppButtonStyles.primaryFilled(
                Theme.of(context).colorScheme,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(
                l10n.settingsImportConfirmAction,
                style: AppTypography.button.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final raw = bytes != null
          ? utf8.decode(bytes)
          : await File(path!).readAsString();
      await _backupService.importJson(raw);

      if (!mounted) return;
      final theme = context.read<ThemeNotifier>();
      final locale = context.read<LocaleNotifier>();
      await theme.reload();
      await locale.reload();
      if (!mounted) return;
      setState(() {
        _mode = theme.mode;
        _locale = locale.locale;
        _seedColor = theme.usesDefaultSeed ? null : theme.seedColor;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsImportSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsImportFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final viewInset = MediaQuery.of(context).viewPadding.bottom;
    return AlertDialog(
      insetPadding: AppInsets.pageWithBottomInset(viewInset),
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
                  : _seedColor?.toARGB32() == option.color!.toARGB32();
              return _SeedOptionRow(
                label: option.label,
                swatch: option.swatch,
                selected: selected,
                onTap: () => _setSeedColor(option.color),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.settingsDataTitle,
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionRow(
              icon: Icons.upload_rounded,
              label: l10n.settingsExportJson,
              onTap: _exportBackup,
            ),
            const SizedBox(height: AppSpacing.xs),
            _ActionRow(
              icon: Icons.download_rounded,
              label: l10n.settingsImportJson,
              onTap: _importBackup,
            ),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
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
