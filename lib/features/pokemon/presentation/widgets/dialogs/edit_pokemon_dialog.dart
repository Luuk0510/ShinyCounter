import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_action_builders.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/dialogs.dart';

class EditPokemonDialog extends StatefulWidget {
  const EditPokemonDialog({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<EditPokemonDialog> createState() => _EditPokemonDialogState();
}

class _EditPokemonDialogState extends State<EditPokemonDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pokemon.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        l10n.editDialogTitle,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.nameLabel,
                hintText: l10n.nameHint,
                labelStyle: const TextStyle(
                  fontSize: AppSizes.sheetFieldLabel,
                  fontWeight: FontWeight.w700,
                ),
                hintStyle: const TextStyle(fontSize: AppSizes.sheetFieldHint),
              ),
              style: const TextStyle(
                fontSize: AppSizes.sheetFieldText,
                fontWeight: FontWeight.w800,
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      actions: [
        DialogActionBar(
          colors: Theme.of(context).colorScheme,
          cancelLabel: l10n.cancel,
          confirmLabel: l10n.save,
          onCancel: () => Navigator.of(context).pop<Pokemon?>(null),
          onConfirm: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;

            Navigator.of(context).pop<Pokemon?>(
              Pokemon(
                id: widget.pokemon.id,
                name: name,
                imagePath: widget.pokemon.imagePath,
                isLocalFile: widget.pokemon.isLocalFile,
              ),
            );
          },
          cancelTextStyle: AppTypography.button,
          confirmTextStyle: AppTypography.button,
        ),
      ],
    );
  }
}

Future<Pokemon?> showEditPokemonDialog(BuildContext context, Pokemon pokemon) {
  return showScaledDialog<Pokemon?>(
    context: context,
    builder: (_) => EditPokemonDialog(pokemon: pokemon),
  );
}
