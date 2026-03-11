import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/data/pokemon_names.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/controller_base.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_ordering.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

const bool _includeBaseDex = false;

class PokemonListPageController extends LoadableController {
  PokemonListPageController({
    required PokemonRepository pokemonRepository,
    required CounterSync counterSync,
    required SpriteService spriteService,
  }) : _pokemonRepository = pokemonRepository,
       _counterSync = counterSync,
       _spriteService = spriteService;

  final PokemonRepository _pokemonRepository;
  final CounterSync _counterSync;
  final SpriteService _spriteService;

  final List<Pokemon> _customPokemon = [];
  final List<Pokemon> _basePokemon = [];
  Set<String> _caught = {};
  bool _showUncaught = true;
  bool _showCaught = true;

  bool get showUncaught => _showUncaught;
  bool get showCaught => _showCaught;
  List<Pokemon> get customPokemon => List.unmodifiable(_customPokemon);
  List<Pokemon> get customPokemonSorted =>
      [..._customPokemon]..sort(pokemonDexComparator);
  List<Pokemon> get uncaughtPokemonSorted =>
      [...uncaughtPokemon]..sort(pokemonDexComparator);
  List<Pokemon> get caughtPokemonSorted =>
      [...caughtPokemon]..sort(pokemonDexComparator);

  List<Pokemon> get allPokemon {
    final combined = [..._basePokemon, ..._customPokemon];
    combined.sort(pokemonDexComparator);
    return combined;
  }

  List<Pokemon> get uncaughtPokemon =>
      allPokemon.where((pokemon) => !isCaught(pokemon)).toList();

  List<Pokemon> get caughtPokemon => allPokemon.where(isCaught).toList();

  bool isCustomPokemon(Pokemon pokemon) {
    return _customPokemon.any((entry) => entry.id == pokemon.id);
  }

  bool isCaught(Pokemon pokemon) => _caught.contains(pokemon.id);

  Future<void> initialize(BuildContext context) async {
    await loadData();
    if (!context.mounted) return;
    await precacheListSprites(context);
  }

  Future<void> refresh(BuildContext context) async {
    await loadData();
    if (!context.mounted) return;
    await precacheListSprites(context);
  }

  Future<void> loadData() async {
    setLoading(true, notify: false);
    if (_includeBaseDex) {
      await _loadBasePokemon();
    }
    final custom = await _pokemonRepository.loadCustomPokemon();
    if (isDisposed) return;
    _customPokemon
      ..clear()
      ..addAll(custom);
    await reloadCaught(notify: false);
    if (isDisposed) return;
    setLoading(false);
  }

  Future<void> reloadCaught({bool notify = true}) async {
    _caught = await _pokemonRepository.loadCaught(allPokemon);
    if (notify) {
      safeNotifyListeners();
    }
  }

  Future<void> addPokemon(Pokemon pokemon) async {
    _customPokemon.add(pokemon);
    await _pokemonRepository.saveCustomPokemon(_customPokemon);
    if (isDisposed) return;
    await reloadCaught(notify: false);
    if (isDisposed) return;
    safeNotifyListeners();
  }

  Future<void> applyPokemonEdit(Pokemon original, Pokemon updated) async {
    final index = _customPokemon.indexWhere(
      (pokemon) => pokemon.id == original.id,
    );
    if (index == -1) return;
    _customPokemon[index] = updated;
    await _pokemonRepository.saveCustomPokemon(_customPokemon);
    if (isDisposed) return;
    await reloadCaught(notify: false);
    if (isDisposed) return;
    safeNotifyListeners();
  }

  Future<void> deletePokemon(Pokemon pokemon) async {
    _customPokemon.removeWhere((entry) => entry.id == pokemon.id);
    await _pokemonRepository.saveCustomPokemon(_customPokemon);
    if (isDisposed) return;
    await reloadCaught(notify: false);
    if (isDisposed) return;
    safeNotifyListeners();
  }

  Future<void> deletePokemonAndState(Pokemon pokemon) async {
    await deletePokemon(pokemon);
    await _counterSync.clearPokemonState(pokemon.id);
  }

  void toggleUncaughtSection() {
    _showUncaught = !_showUncaught;
    safeNotifyListeners();
  }

  void toggleCaughtSection() {
    _showCaught = !_showCaught;
    safeNotifyListeners();
  }

  Future<void> precacheListSprites(BuildContext context) async {
    final toPrecache = allPokemon
        .where((pokemon) => !pokemon.isLocalFile)
        .take(AppLimits.listSpritePrecacheCount)
        .toList();
    if (toPrecache.isEmpty) return;
    await _spriteService.precacheSpritePaths(
      context,
      toPrecache.map((pokemon) => pokemon.imagePath),
    );
    final dexes = <String>[];
    for (final pokemon in toPrecache) {
      final parsed = SpriteParser.parse(pokemon.imagePath.split('/').last);
      if (parsed != null) dexes.add(parsed.dex);
    }
    if (dexes.isNotEmpty) {
      await _spriteService.warmupForDexes(dexes);
    }
  }

  int? _genderPriority(String token) {
    switch (token) {
      case 'm':
      case 'md':
      case 'mo':
        return 0;
      case 'mf':
      case 'uk':
        return 1;
      case 'f':
      case 'fd':
      case 'fo':
        return 2;
      default:
        return null;
    }
  }

  Future<void> _loadBasePokemon() async {
    if (_basePokemon.isNotEmpty) return;
    try {
      final names = await PokemonNames.load();
      final sprites = await _spriteService.loadSprites();
      if (isDisposed) return;
      final chosen = <String, ParsedSprite>{};
      for (final sprite in sprites) {
        if (!sprite.shiny) continue;
        if (isMegaOrGmaxForm(sprite.form)) continue;
        final priority = _genderPriority(sprite.gender);
        if (priority == null) continue;
        final current = chosen[sprite.dex];
        if (current == null ||
            priority < _genderPriority(current.gender)! ||
            (priority == _genderPriority(current.gender)! &&
                sprite.form.compareTo(current.form) < 0)) {
          chosen[sprite.dex] = sprite;
        }
      }

      _basePokemon
        ..clear()
        ..addAll(
          chosen.values.map(
            (sprite) => Pokemon(
              id: sprite.dex,
              name: names.nameFor(sprite.dex),
              imagePath: sprite.path,
              isLocalFile: false,
            ),
          ),
        );
      _basePokemon.sort(pokemonDexComparator);
    } catch (_) {
      // If assets fail to load we leave the base list empty; the UI still works
      // with custom Pokemon.
    }
  }
}
