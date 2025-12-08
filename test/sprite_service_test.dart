import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';

class _FakeBundle extends AssetBundle {
  _FakeBundle(this.assetKeys);

  final List<String> assetKeys;

  @override
  Future<ByteData> load(String key) async => ByteData(0);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'AssetManifest.json') {
      final map = {for (final k in assetKeys) k: []};
      return jsonEncode(map);
    }
    return '';
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async {
    final data = await loadString(key);
    return parser(data);
  }

  @override
  void evict(String key) {}
}

void main() {
  test('loadSprites parses assets and caches by dex', () async {
    final bundle = _FakeBundle([
      'assets/pokemons/0001_form_m_n.png',
      'assets/pokemons/0002_form_f_s.png',
      'assets/ignore/me.txt',
    ]);
    final repo = SpriteRepository(bundle: bundle);

    final all = await repo.loadSprites();
    expect(all.length, 2);
    expect(all.first.dex, '0001');

    final dex2 = await repo.spritesForDex('0002');
    expect(dex2.single.shiny, isTrue);

    // Cached call without refresh should return existing slice.
    final cached = await repo.spritesForDex('0002');
    expect(cached.length, 1);
  });

  test('warmupForDexes indexes requested dexes', () async {
    final bundle = _FakeBundle([
      'assets/pokemons/0003_form_m_n.png',
      'assets/pokemons/0004_form_m_n.png',
    ]);
    final repo = SpriteRepository(bundle: bundle);

    await repo.warmupForDexes(['0003']);
    final dex3 = await repo.spritesForDex('0003');
    expect(dex3.single.dex, '0003');

    await repo.warmupForDexes(['0004'], refresh: true);
    final dex4 = await repo.spritesForDex('0004');
    expect(dex4.single.dex, '0004');
  });
}
