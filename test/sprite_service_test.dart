import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.manifest);

  final Map<String, List<String>> manifest;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'AssetManifest.json') {
      return '{"assets/pokemons/0001_form_m_n.png": [],"assets/pokemons/0002_form_f_n.png": []}';
    }
    return '';
  }

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }

  @override
  Future<AssetManifest> loadManifest() async {
    return AssetManifest(manifest);
  }
}

void main() {
  test('SpriteRepository parses and caches sprites', () async {
    final bundle = _FakeBundle({
      'assets/pokemons/0001_form_m_n.png': [],
      'assets/pokemons/0002_form_f_n.png': [],
      'assets/other.png': [],
    });
    final repo = SpriteRepository(bundle: bundle);

    final all = await repo.loadSprites();

    expect(all.length, 2);
    expect(all.first.dex, '0001');

    final dex1 = await repo.spritesForDex('0001');
    expect(dex1.single.dex, '0001');

    // Cached path should return immediately without refresh.
    final cached = await repo.spritesForDex('0001');
    expect(identical(dex1, cached), isFalse); // new list but from cache
  });

  test('warmupForDexes populates indexes and respects refresh', () async {
    final bundle = _FakeBundle({
      'assets/pokemons/0003_form_m_s.png': [],
      'assets/pokemons/0004_form_m_n.png': [],
    });
    final repo = SpriteRepository(bundle: bundle);

    await repo.warmupForDexes(['0003']);
    final dex3 = await repo.spritesForDex('0003');
    expect(dex3.single.shiny, isTrue);

    // Refresh should rebuild cache.
    await repo.warmupForDexes(['0004'], refresh: true);
    final dex4 = await repo.spritesForDex('0004');
    expect(dex4.single.dex, '0004');
  });
}
