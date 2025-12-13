import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class TestAssetBundle extends AssetBundle {
  TestAssetBundle(Iterable<String> assetKeys)
    : _assetKeys = Set<String>.from(assetKeys);

  final Set<String> _assetKeys;

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

  Map<String, dynamic> get _manifest => {for (final k in _assetKeys) k: []};

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      final codec = const StandardMessageCodec();
      final bytes = codec.encodeMessage(_manifest)!;
      return bytes;
    }
    if (key == 'AssetManifest.json') {
      final data = utf8.encode(jsonEncode(_manifest));
      return ByteData.view(Uint8List.fromList(data).buffer);
    }
    if (key == 'assets/data/pokemon_names_en.json') {
      final data = utf8.encode(
        jsonEncode(<String, String>{
          '0001': 'Bulbasaur',
          '0152': 'Chikorita',
          '0252': 'Treecko',
        }),
      );
      return ByteData.view(Uint8List.fromList(data).buffer);
    }
    return ByteData.view(_pngBytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'AssetManifest.json') return jsonEncode(_manifest);
    if (key == 'assets/data/pokemon_names_en.json') {
      return jsonEncode(<String, String>{
        '0001': 'Bulbasaur',
        '0152': 'Chikorita',
        '0252': 'Treecko',
      });
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
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    final data = await load(key);
    return parser(data);
  }

  @override
  void evict(String key) {}
}
