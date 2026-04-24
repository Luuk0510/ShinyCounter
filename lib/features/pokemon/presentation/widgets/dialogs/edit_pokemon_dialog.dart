import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_field_styles.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_action_builders.dart';
import 'package:shiny_counter/features/pokemon/presentation/utils/dialogs.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_actions.dart';

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
              decoration: PokemonFieldDecorations.standard(
                labelText: l10n.nameLabel,
                hintText: l10n.nameHint,
              ),
              style: PokemonFieldStyles.input,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: dialogActionsPadding,
      actions: dialogActions(
        context: context,
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
      ),
    );
  }
}

Future<Pokemon?> showEditPokemonDialog(BuildContext context, Pokemon pokemon) {
  return showScaledDialog<Pokemon?>(
    context: context,
    builder: (_) => EditPokemonDialog(pokemon: pokemon),
  );
}
