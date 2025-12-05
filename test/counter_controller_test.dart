import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/counter_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CounterSync sync;
  late ToggleCaughtUseCase toggleCaught;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sync = await CounterSyncService.instance();
    await (await SharedPreferences.getInstance()).clear();
    toggleCaught = ToggleCaughtUseCase(sync);
    debugDefaultTargetPlatformOverride =
        TargetPlatform.iOS; // disable overlay usage in tests
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  CounterController buildController() {
    return CounterController(
      pokemon: const Pokemon(
        id: 'p-test',
        name: 'Testmon',
        imagePath: 'assets/icon/pokeball_icon.png',
      ),
      sync: sync,
      toggleCaughtUseCase: toggleCaught,
    );
  }

  test('increment sets counter and start date', () async {
    final controller = buildController();
    await controller.init();

    await controller.increment();

    expect(controller.counter, 1);
    expect(controller.startedAt, isNotNull);
    expect(controller.dailyCounts.isNotEmpty, isTrue);
    controller.dispose();
  });

  test('resetting counter clears caught state', () async {
    final controller = buildController();
    await controller.init();

    await controller.setCounterManual(3);
    await controller.toggleCaught();
    expect(controller.isCaught, isTrue);

    await controller.setCounterManual(0);

    expect(controller.counter, 0);
    expect(controller.isCaught, isFalse);
    expect(controller.caughtAt, isNull);
    controller.dispose();
  });

  test('toggleOverlay is guarded on unsupported platforms', () async {
    final controller = buildController();
    await controller.init();

    await controller.toggleOverlay();

    expect(controller.pillActive, isFalse);
    controller.dispose();
  });
}
