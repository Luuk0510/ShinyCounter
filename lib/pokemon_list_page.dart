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
      _customPokemon.add(newPokemon);
    });
    await _storage.saveCustomPokemon(_customPokemon);
    await _reloadCaught();
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
            icon: const Icon(Icons.add),
            tooltip: 'Nieuwe Pokémon',
            onPressed: _onAddPokemon,
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
                  itemCount: _allPokemon.length,
                  itemBuilder: (context, index) {
                    final pokemon = _allPokemon[index];
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
