import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

abstract class SpriteService {
  Future<List<ParsedSprite>> loadSprites({bool refresh = false});
  Future<List<ParsedSprite>> spritesForDex(String dex, {bool refresh = false});
}

class SpriteRepository implements SpriteService {
  SpriteRepository({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;
  List<ParsedSprite>? _cache;
  final Map<String, List<ParsedSprite>> _byDex = {};

  AssetBundle get _assetBundle => _bundle ?? rootBundle;

  @override
  Future<List<ParsedSprite>> loadSprites({bool refresh = false}) async {
    if (!refresh && _cache != null) return _cache!;
    final parsed = await _load();
    _cache = parsed;
    _byDex.clear();
    for (final sprite in parsed) {
      _byDex.putIfAbsent(sprite.dex, () => []).add(sprite);
    }
    return parsed;
  }

  @override
  Future<List<ParsedSprite>> spritesForDex(String dex,
      {bool refresh = false}) async {
    if (!refresh && _byDex.containsKey(dex)) {
      return _byDex[dex]!;
    }
    final all = await loadSprites(refresh: refresh);
    final filtered = all.where((p) => p.dex == dex).toList();
    _byDex[dex] = filtered;
    return filtered;
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
