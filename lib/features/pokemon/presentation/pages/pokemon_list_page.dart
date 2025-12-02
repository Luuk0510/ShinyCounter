import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/core/routing/app_router.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/add_pokemon_dialog.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/pokemon_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/pokemon_empty_state.dart';

const _basePokemon = <Pokemon>[];

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  late final LoadCustomPokemonUseCase _loadCustomPokemon;
  late final SaveCustomPokemonUseCase _saveCustomPokemon;
  late final LoadCaughtUseCase _loadCaught;
  final List<Pokemon> _customPokemon = [];
  Set<String> _caught = {};
  bool _loading = true;

  List<Pokemon> get _allPokemon => [..._basePokemon, ..._customPokemon];

  @override
  void initState() {
    super.initState();
    _loadCustomPokemon = context.read<LoadCustomPokemonUseCase>();
    _saveCustomPokemon = context.read<SaveCustomPokemonUseCase>();
    _loadCaught = context.read<LoadCaughtUseCase>();
    _loadData();
  }

  Future<void> _loadData() async {
    final custom = await _loadCustomPokemon();
    setState(() {
      _customPokemon
        ..clear()
        ..addAll(custom);
    });
    await _reloadCaught();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _reloadCaught() async {
    final caught = await _loadCaught(_allPokemon);
    if (mounted) {
      setState(() => _caught = caught);
    }
  }

  bool _isCaught(Pokemon pokemon) => _caught.contains(pokemon.name);

  Future<void> _onAddPokemon() async {
    final newPokemon = await showAddPokemonDialog(context);
    if (newPokemon == null) return;

    setState(() {
      _customPokemon.add(newPokemon);
    });
    await _saveCustomPokemon(_customPokemon);
    await _reloadCaught();
  }

  Future<void> _onEditPokemonList() async {
    final pokemonSorted = [..._customPokemon]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (pokemonSorted.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen custom Pokémon om te bewerken.')),
        );
      }
      return;
    }

    final selected = await showModalBottomSheet<Pokemon>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecteer Pokémon om te bewerken',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pokemonSorted.length,
                  itemBuilder: (context, index) {
                    final p = pokemonSorted[index];
                    return ListTile(
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () => Navigator.of(context).pop(p),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      final updated = await showEditPokemonDialog(context, selected);
      if (updated != null) {
        await _applyPokemonEdit(selected, updated);
      }
    }
  }

  Future<void> _applyPokemonEdit(Pokemon original, Pokemon updated) async {
    final index = _customPokemon.indexWhere(
      (p) => p.name == original.name && p.imagePath == original.imagePath,
    );
    if (index == -1) return;

    setState(() {
      _customPokemon[index] = updated;
    });

    await _saveCustomPokemon(_customPokemon);
    await _migratePokemonState(original, updated);
    await _reloadCaught();
  }

  Future<void> _migratePokemonState(Pokemon original, Pokemon updated) async {
    if (original.name.toLowerCase() == updated.name.toLowerCase()) return;

    final prefs = await SharedPreferences.getInstance();
    final oldCounterKey = 'counter_${original.name.toLowerCase()}';
    final newCounterKey = 'counter_${updated.name.toLowerCase()}';
    final oldCaughtKey = 'caught_${original.name.toLowerCase()}';
    final newCaughtKey = 'caught_${updated.name.toLowerCase()}';
    final oldStartedKey = '${oldCounterKey}_startedAt';
    final newStartedKey = '${newCounterKey}_startedAt';
    final oldCaughtAtKey = '${oldCounterKey}_caughtAt';
    final newCaughtAtKey = '${newCounterKey}_caughtAt';
    final oldDailyCountsKey = '${oldCounterKey}_dailyCounts';
    final newDailyCountsKey = '${newCounterKey}_dailyCounts';

    final oldCounter = prefs.getInt(oldCounterKey);
    final oldCaught = prefs.getBool(oldCaughtKey);
    final oldStartedAt = prefs.getString(oldStartedKey);
    final oldCaughtAt = prefs.getString(oldCaughtAtKey);
    final oldDailyCounts = prefs.getString(oldDailyCountsKey);

    if (oldCounter != null) {
      await prefs.setInt(newCounterKey, oldCounter);
    }
    if (oldCaught != null) {
      await prefs.setBool(newCaughtKey, oldCaught);
    }
    if (oldStartedAt != null) {
      await prefs.setString(newStartedKey, oldStartedAt);
    }
    if (oldCaughtAt != null) {
      await prefs.setString(newCaughtAtKey, oldCaughtAt);
    }
    if (oldDailyCounts != null) {
      await prefs.setString(newDailyCountsKey, oldDailyCounts);
    }

    await prefs.remove(oldCounterKey);
    await prefs.remove(oldCaughtKey);
    await prefs.remove(oldStartedKey);
    await prefs.remove(oldCaughtAtKey);
    await prefs.remove(oldDailyCountsKey);
  }

  Future<void> _clearPokemonState(Pokemon pokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final counterKey = 'counter_${pokemon.name.toLowerCase()}';
    await prefs.remove(counterKey);
    await prefs.remove('caught_${pokemon.name.toLowerCase()}');
    await prefs.remove('${counterKey}_startedAt');
    await prefs.remove('${counterKey}_caughtAt');
    await prefs.remove('${counterKey}_dailyCounts');
  }

  Future<void> _confirmDelete(Pokemon pokemon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verwijderen'),
          content: Text.rich(
            TextSpan(
              text: 'Weet je zeker dat je ',
              children: [
                TextSpan(
                  text: pokemon.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: ' wilt verwijderen?',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Verwijder'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _customPokemon.removeWhere((p) => p.name == pokemon.name && p.imagePath == pokemon.imagePath);
      });
      await _saveCustomPokemon(_customPokemon);
      await _clearPokemonState(pokemon);
      await _reloadCaught();
    }
  }

  Future<void> _onDeletePokemonList() async {
    final pokemonSorted = [..._allPokemon]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (pokemonSorted.isEmpty) return;

    final selected = await showModalBottomSheet<Pokemon>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecteer Pokémon om te verwijderen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pokemonSorted.length,
                  itemBuilder: (context, index) {
                    final p = pokemonSorted[index];
                    return ListTile(
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      trailing: const Icon(Icons.delete_outline),
                      onTap: () => Navigator.of(context).pop(p),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await _confirmDelete(selected);
    }
  }

  Future<void> _openDetail(Pokemon pokemon) async {
    await context.push(AppRoutes.pokemonDetail, extra: pokemon);
    await _reloadCaught();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final uncaught = _allPokemon
        .where((p) => !_isCaught(p))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final caught = _allPokemon
        .where((p) => _isCaught(p))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: _buildAppBar(colors),
      body: _buildBody(colors, bottomPadding, uncaught, caught),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colors) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 52,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.82),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
        ),
      ),
      foregroundColor: colors.onSurface,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: const Text(
          'Pokémon shiny counter',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      actions: [
        IconButton(
          iconSize: 26,
          icon: const Icon(Icons.add_circle),
          tooltip: 'Nieuwe Pokémon',
          onPressed: _onAddPokemon,
        ),
        IconButton(
          iconSize: 26,
          icon: const Icon(Icons.edit),
          tooltip: 'Bewerk Pokémon',
          onPressed: _onEditPokemonList,
        ),
        IconButton(
          iconSize: 26,
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Verwijder Pokémon',
          onPressed: _onDeletePokemonList,
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme colors, double bottomPadding, List<Pokemon> uncaught, List<Pokemon> caught) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allPokemon.isEmpty) {
      return PokemonEmptyState(
        onAddPressed: _onAddPokemon,
        imageAsset: 'assets/icon/pokeball_icon.png',
        colors: colors,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0, 4, 0, bottomPadding),
      itemCount: _sectionedCount(uncaught, caught),
      itemBuilder: (context, index) {
        final entry = _sectionedItem(uncaught, caught, index);
        if (entry is _SectionHeader) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              entry.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        } else if (entry is Pokemon) {
          return PokemonCard(
            pokemon: entry,
            isCaught: _isCaught(entry),
            onTap: () => _openDetail(entry),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

int _sectionedCount(List<Pokemon> uncaught, List<Pokemon> caught) {
  var count = 0;
  if (uncaught.isNotEmpty) {
    count += 1 + uncaught.length;
  }
  if (caught.isNotEmpty) {
    count += 1 + caught.length;
  }
  return count;
}

dynamic _sectionedItem(List<Pokemon> uncaught, List<Pokemon> caught, int index) {
  var cursor = 0;

  if (uncaught.isNotEmpty) {
    if (index == cursor) return const _SectionHeader('Niet gevangen');
    cursor += 1;
    if (index < cursor + uncaught.length) {
      return uncaught[index - cursor];
    }
    cursor += uncaught.length;
  }

  if (caught.isNotEmpty) {
    if (index == cursor) return const _SectionHeader('Gevangen');
    cursor += 1;
    if (index < cursor + caught.length) {
      return caught[index - cursor];
    }
  }

  return null;
}

class _SectionHeader {
  const _SectionHeader(this.title);
  final String title;
}

class _EditPokemonDialog extends StatefulWidget {
  const _EditPokemonDialog({required this.pokemon});

  final Pokemon pokemon;

  @override
  State<_EditPokemonDialog> createState() => _EditPokemonDialogState();
}

class _EditPokemonDialogState extends State<_EditPokemonDialog> {
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
    return AlertDialog(
      title: const Text('Pokémon bewerken'),
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
          child: const Text('Annuleren'),
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
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}

Future<Pokemon?> showEditPokemonDialog(BuildContext context, Pokemon pokemon) {
  return showDialog<Pokemon?>(
    context: context,
    builder: (_) => _EditPokemonDialog(pokemon: pokemon),
  );
}
