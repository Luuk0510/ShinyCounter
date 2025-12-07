import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

abstract class SpriteService {
  Future<List<ParsedSprite>> loadSprites({bool refresh = false});
  Future<List<ParsedSprite>> spritesForDex(String dex, {bool refresh = false});
  Future<void> warmupForDexes(Iterable<String> dexes, {bool refresh = false});
}

class SpriteRepository implements SpriteService {
  SpriteRepository({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;
  List<ParsedSprite>? _cache;
  final Map<String, List<ParsedSprite>> _byDex = {};
  final Map<String, Map<String, ParsedSprite>> _byDexForm = {};

  AssetBundle get _assetBundle => _bundle ?? rootBundle;

  @override
  Future<List<ParsedSprite>> loadSprites({bool refresh = false}) async {
    if (!refresh && _cache != null) return _cache!;
    final parsed = await _load();
    _cache = parsed;
    _byDex.clear();
    _byDexForm.clear();
    for (final sprite in parsed) {
      _byDex.putIfAbsent(sprite.dex, () => []).add(sprite);
      _indexVariant(sprite);
    }
    return parsed;
  }

  @override
  Future<List<ParsedSprite>> spritesForDex(
    String dex, {
    bool refresh = false,
  }) async {
    if (!refresh && _byDex.containsKey(dex)) {
      return _byDex[dex]!;
    }
    final all = await loadSprites(refresh: refresh);
    final filtered = all.where((p) => p.dex == dex).toList();
    _byDex[dex] = filtered;
    for (final sprite in filtered) {
      _indexVariant(sprite);
    }
    return filtered;
  }

  @override
  Future<void> warmupForDexes(
    Iterable<String> dexes, {
    bool refresh = false,
  }) async {
    if (dexes.isEmpty) return;
    final deduped = dexes.toSet();
    if (!refresh &&
        deduped.every(
          (dex) => _byDex.containsKey(dex) && _byDexForm.containsKey(dex),
        )) {
      return;
    }
    final all = await loadSprites(refresh: refresh);
    for (final dex in deduped) {
      if (_byDex.containsKey(dex) && !refresh) continue;
      final filtered = all.where((p) => p.dex == dex).toList();
      _byDex[dex] = filtered;
      for (final sprite in filtered) {
        _indexVariant(sprite);
      }
    }
  }

  void _indexVariant(ParsedSprite sprite) {
    final byForm = _byDexForm.putIfAbsent(sprite.dex, () => {});
    final key = '${sprite.form}|${sprite.gender}|${sprite.shiny}';
    byForm[key] = sprite;
  }

  Future<List<ParsedSprite>> _load() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(_assetBundle);
      final assets = manifest.listAssets();
      return _parseAssets(assets);
    } catch (_) {
      try {
        final manifestString = await _assetBundle.loadString(
          'AssetManifest.json',
        );
        final manifest = jsonDecode(manifestString) as Map<String, dynamic>;
        final assets = manifest.keys;
        return _parseAssets(assets);
      } catch (_) {
        return const [];
      }
    }
  }

  List<ParsedSprite> _parseAssets(Iterable<String> assets) {
    return assets
        .where(
          (key) =>
              key.contains('assets/pokemons/') &&
              key.toLowerCase().endsWith('.png'),
        )
        .map(SpriteParser.parse)
        .whereType<ParsedSprite>()
        .toList();
  }
}
