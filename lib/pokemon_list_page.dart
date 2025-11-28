import 'package:flutter/material.dart';

import 'add_pokemon_dialog.dart';
import 'pokemon.dart';
import 'pokemon_card.dart';
import 'pokemon_detail_page.dart';
import 'pokemon_empty_state.dart';
import 'pokemon_storage.dart';

const _basePokemon = <Pokemon>[];

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final _storage = PokemonStorage();
  final List<Pokemon> _customPokemon = [];
  Set<String> _caught = {};
  bool _loading = true;

  List<Pokemon> get _allPokemon => [..._basePokemon, ..._customPokemon];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final custom = await _storage.loadCustomPokemon();
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
    final caught = await _storage.loadCaught(_allPokemon);
    if (mounted) {
      setState(() => _caught = caught);
    }
  }

  bool _isCaught(Pokemon pokemon) => _caught.contains(pokemon.name);

  Future<void> _onAddPokemon() async {
    final newPokemon = await showAddPokemonDialog(context);
    if (newPokemon == null) return;

    setState(() {
      _customPokemon
        ..add(newPokemon)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
    await _storage.saveCustomPokemon(_customPokemon);
    await _reloadCaught();
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
      await _storage.saveCustomPokemon(_customPokemon);
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
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecteer Pokémon om te verwijderen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pokemonSorted.length,
                  itemBuilder: (context, index) {
                    final p = pokemonSorted[index];
                    return ListTile(
                      title: Text(p.name),
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(pokemon: pokemon),
      ),
    );
    await _reloadCaught();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pokemonSorted = [..._allPokemon]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        centerTitle: true,
        toolbarHeight: 40,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: const Text(
          'Pokémon shiny counter',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: colors.outlineVariant,
          ),
        ),
        actions: [
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.add_circle),
            tooltip: 'Nieuwe Pokémon',
            onPressed: _onAddPokemon,
          ),
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Verwijder Pokémon',
            onPressed: _onDeletePokemonList,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allPokemon.isEmpty
              ? PokemonEmptyState(
                  onAddPressed: _onAddPokemon,
                  imageAsset: 'assets/icon/pokeball_icon.png',
                  colors: colors,
                )
              : ListView.builder(
                  itemCount: pokemonSorted.length,
                  itemBuilder: (context, index) {
                    final pokemon = pokemonSorted[index];
                    return PokemonCard(
                      pokemon: pokemon,
                      isCaught: _isCaught(pokemon),
                      onTap: () => _openDetail(pokemon),
                    );
                  },
                ),
    );
  }
}
