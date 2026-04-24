import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';

class _FakeBundle extends AssetBundle {
  _FakeBundle(this.assetKeys);

  final List<String> assetKeys;
  int manifestLoads = 0;

  @override
  Future<ByteData> load(String key) async => ByteData(0);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'AssetManifest.json') {
      manifestLoads++;
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

class _CountingBundle extends AssetBundle {
  final Map<String, int> loads = {};
  static final Uint8List _pngBytes = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x60,
    0x00,
    0x00,
    0x00,
    0x02,
    0x00,
    0x01,
    0xE2,
    0x21,
    0xBC,
    0x33,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);

  @override
  Future<ByteData> load(String key) async {
    loads[key] = (loads[key] ?? 0) + 1;
    return ByteData.view(_pngBytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loads[key] = (loads[key] ?? 0) + 1;
    if (key == 'AssetManifest.json') {
      return jsonEncode({'assets/pokemons/0001_form_m_n.png': []});
    }
    return '';
  }

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    loads[key] = (loads[key] ?? 0) + 1;
    if (key == 'AssetManifest.bin') {
      final manifest = {'assets/pokemons/0001_form_m_n.png': <String>[]};
      final codec = const StandardMessageCodec();
      final bytes = codec.encodeMessage(manifest)!;
      return parser(bytes);
    }
    return parser(ByteData(0));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadSprites parses assets and caches by dex', () async {
    final bundle = _FakeBundle([
      'assets/pokemons/0001_form_m_n.png',
      'assets/pokemons/0002_form_f_s.png',
      'assets/ignore/me.txt',
    ]);
    final repo = PokemonSpriteService(bundle: bundle);

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
    final repo = PokemonSpriteService(bundle: bundle);

    await repo.warmupForDexes(['0003']);
    final dex3 = await repo.spritesForDex('0003');
    expect(dex3.single.dex, '0003');

    await repo.warmupForDexes(['0004'], refresh: true);
    final dex4 = await repo.spritesForDex('0004');
    expect(dex4.single.dex, '0004');
  });

  testWidgets('precacheSpritePaths dedupes and ignores non-assets', (
    tester,
  ) async {
    final bundle = _CountingBundle();
    final repo = PokemonSpriteService(bundle: bundle);

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultAssetBundle(
          bundle: bundle,
          child: Builder(
            builder: (context) {
              repo.precacheSpritePaths(context, [
                'assets/pokemons/0001_form_m_n.png',
                'assets/pokemons/0001_form_m_n.png',
                'http://example.com/skip.png',
              ], dedupe: true);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(bundle.loads['assets/pokemons/0001_form_m_n.png'], 1);
    expect(bundle.loads.containsKey('http://example.com/skip.png'), isFalse);
  });

  test('warmupForDexes skips cached dexes unless refresh is true', () async {
    final bundle = _FakeBundle(['assets/pokemons/0005_form_m_n.png']);
    final repo = PokemonSpriteService(bundle: bundle);

    await repo.warmupForDexes(['0005']);
    expect(bundle.manifestLoads, 1);

    // Cached: no additional manifest load.
    await repo.warmupForDexes(['0005']);
    expect(bundle.manifestLoads, 1);

    // Refresh forces reload.
    await repo.warmupForDexes(['0005'], refresh: true);
    expect(bundle.manifestLoads, 2);
  });
}
