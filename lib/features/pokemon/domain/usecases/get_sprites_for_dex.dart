import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

class GetSpritesForDex {
  GetSpritesForDex(this._service);

  final SpriteService _service;

  /// Fetch sprites for a given dex entry; pass [refresh] to bypass caches.
  Future<List<ParsedSprite>> call(String dex, {bool refresh = false}) {
    return _service.spritesForDex(dex, refresh: refresh);
  }

  /// Warm up caches for a set of dex numbers (optional helper).
  Future<void> warmup(Iterable<String> dexes, {bool refresh = false}) {
    return _service.warmupForDexes(dexes, refresh: refresh);
  }
}
