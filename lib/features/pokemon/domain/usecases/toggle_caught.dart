import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';

class ToggleCaughtUseCase {
  ToggleCaughtUseCase(this._sync);

  final CounterSyncService _sync;

  Future<void> call(String caughtKey, bool isCaught) => _sync.setCaught(caughtKey, isCaught);
}
