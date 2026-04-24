import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';

class ToggleCaughtUseCase {
  ToggleCaughtUseCase(this._sync);

  final CounterSync _sync;

  Future<void> call(String caughtKey, bool isCaught) =>
      _sync.setCaught(caughtKey, isCaught);
}
