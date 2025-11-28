import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
<<<<<<< Updated upstream
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final Set<String> _caught = {};
=======
  final _storage = PokemonStorage();
  final List<Pokemon> _customPokemon = [];
  Set<String> _caught = {};
  bool _loading = true;

  List<Pokemon> get _allPokemon => [..._basePokemon, ..._customPokemon];
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
<<<<<<< Updated upstream
    _loadCaught();
  }

  Future<void> _loadCaught() async {
    final prefs = await _prefs;
    setState(() {
      _caught
        ..clear()
        ..addAll(_pokemonList.where((p) => prefs.getBool(_keyFor(p)) ?? false).map((p) => p.name));
    });
  }

  String _keyFor(Pokemon pokemon) => 'caught_${pokemon.name.toLowerCase()}';
  bool _isCaught(Pokemon pokemon) => _caught.contains(pokemon.name);

=======
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

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
      ),
      body: ListView.builder(
        itemCount: _pokemonList.length,
        itemBuilder: (context, index) {
          final pokemon = _pokemonList[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PokemonDetailPage(pokemon: pokemon),
                    ),
                  );
                  await _loadCaught();
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ColorFiltered(
                          colorFilter: _isCaught(pokemon)
                              ? const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.dst,
                                )
                              : const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0, 0, 0, 1, 0,
                                ]),
                          child: Image.asset(
                            pokemon.imagePath,
                            width: 140,
                            height: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.catching_pokemon, size: 64),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          pokemon.name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 28),
                    ],
                  ),
=======
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
>>>>>>> Stashed changes
                ),
    );
  }
}
