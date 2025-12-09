import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialog_entry.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/game_dropdown.dart';

class EditPokemonDialog extends StatefulWidget {
  const EditPokemonDialog({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<EditPokemonDialog> createState() => _EditPokemonDialogState();
}

class _EditPokemonDialogState extends State<EditPokemonDialog> {
  late final TextEditingController _nameController;
  String? _game;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pokemon.name);
    _game = null; // Game isn’t part of the core Pokemon model; keep selection local.
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DialogEntry(
      child: AlertDialog(
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
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.gameSelectWidth,
                  ),
                  child: GameDropdown(
                    value: _game,
                    onChanged: (game) => setState(() => _game = game),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop<Pokemon?>(null),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text(l10n.cancel, style: AppTypography.button),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            onPressed: () {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text(l10n.save, style: AppTypography.button),
          ),
        ],
      ),
    );
  }
}

Future<Pokemon?> showEditPokemonDialog(BuildContext context, Pokemon pokemon) {
  return showDialog<Pokemon?>(
    context: context,
    builder: (_) => EditPokemonDialog(pokemon: pokemon),
  );
}
