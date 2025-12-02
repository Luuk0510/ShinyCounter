import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';

class AddPokemonDialog extends StatefulWidget {
  const AddPokemonDialog({super.key});

  @override
  State<AddPokemonDialog> createState() => _AddPokemonDialogState();
}

class _AddPokemonDialogState extends State<AddPokemonDialog> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nieuwe Pokémon'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Naam',
              hintText: 'Bijv. Mewtwo',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => _pickedImage = picked);
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Kies foto'),
              ),
              const SizedBox(width: 12),
              if (_pickedImage != null)
                Expanded(
                  child: Text(
                    _pickedImage!.name,
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
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty && _pickedImage != null) {
              Navigator.of(context).pop<Pokemon?>(
                Pokemon(
                  name: name,
                  imagePath: _pickedImage!.path,
                  isLocalFile: true,
                ),
              );
            }
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}

Future<Pokemon?> showAddPokemonDialog(BuildContext context) {
  return showDialog<Pokemon?>(
    context: context,
    builder: (_) => const AddPokemonDialog(),
  );
}
