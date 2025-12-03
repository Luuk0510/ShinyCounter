import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

class EditPokemonDialog extends StatefulWidget {
  const EditPokemonDialog({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<EditPokemonDialog> createState() => _EditPokemonDialogState();
}

class _EditPokemonDialogState extends State<EditPokemonDialog> {
  late final TextEditingController _nameController;
  final _picker = ImagePicker();
  XFile? _pickedImage;

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

  String get _currentImageLabel {
    if (_pickedImage != null) return _pickedImage!.name;
    final segments = widget.pokemon.imagePath.split('/');
    return segments.isNotEmpty ? segments.last : widget.pokemon.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editDialogTitle),
      content: Column(
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
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() => _pickedImage = picked);
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.choosePhoto),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentImageLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<Pokemon?>(null),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;

            var imagePath = widget.pokemon.imagePath;
            var isLocalFile = widget.pokemon.isLocalFile;

            if (_pickedImage != null) {
              imagePath = _pickedImage!.path;
              isLocalFile = true;
            }

            Navigator.of(context).pop<Pokemon?>(
              Pokemon(
                name: name,
                imagePath: imagePath,
                isLocalFile: isLocalFile,
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

Future<Pokemon?> showEditPokemonDialog(BuildContext context, Pokemon pokemon) {
  return showDialog<Pokemon?>(
    context: context,
    builder: (_) => EditPokemonDialog(pokemon: pokemon),
  );
}
