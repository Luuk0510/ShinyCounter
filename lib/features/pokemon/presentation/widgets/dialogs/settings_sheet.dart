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
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/settings_sections.dart';
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
    _seedColor = context.read<ThemeNotifier>().seedColor;
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
        _seedColor = theme.seedColor;
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
    final colors = Theme.of(context).colorScheme;
    final viewInset = MediaQuery.of(context).viewPadding.bottom;
    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm + viewInset,
      ),
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        AppLocalizations.of(context)!.tooltipSettings,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LanguageSection(
              selectedLocale: _locale,
              onLocaleChanged: _setLocale,
            ),
            const SizedBox(height: AppSpacing.lg),
            ThemeSection(mode: _mode, onModeChanged: _setMode),
            const SizedBox(height: AppSpacing.lg),
            AccentColorSection(
              seedColor: _seedColor,
              onSeedColorChanged: _setSeedColor,
            ),
            const SizedBox(height: AppSpacing.lg),
            DataSection(onExport: _exportBackup, onImport: _importBackup),
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
                  AppLocalizations.of(context)!.cancel,
                  style: AppTypography.button.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'v2.2.1',
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
