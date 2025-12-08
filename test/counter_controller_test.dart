import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/state/counter_controller.dart';

import 'helpers/fakes.dart';

void main() {
  const pokemon = Pokemon(
    id: '001',
    name: 'Bulbasaur',
    imagePath: 'assets/001.png',
  );

  group('CounterController', () {
    String todayKey() {
      final now = DateTime.now().toLocal();
      String two(int v) => v.toString().padLeft(2, '0');
      return '${now.year}-${two(now.month)}-${two(now.day)}';
    }

    test('increment persists count and daily delta', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);

      await controller.increment();

      expect(controller.counter, 1);
      expect(sync.counters['counter_001'], 1);
      expect(sync.daily['counter_001'], isNotNull);
    });

    test('toggleCaught updates state and caught timestamp', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);

      await controller.toggleCaught();

      expect(controller.isCaught, isTrue);
      expect(sync.caught['caught_001'], isTrue);
      expect(sync.caughtAt['counter_001'], isNotNull);
    });

    test('setCounter to zero clears caught state and game', () async {
      final sync = FakeCounterSync();
      sync.caught['caught_001'] = true;
      sync.caughtGame['counter_001'] = 'violet';
      sync.counters['counter_001'] = 10;
      final controller = CounterController(pokemon: pokemon, sync: sync);
      await controller.init();

      await controller.setCounter(0);

      expect(controller.counter, 0);
      expect(controller.isCaught, isFalse);
      expect(controller.caughtGame, isNull);
      expect(sync.caught['caught_001'], isFalse);
      expect(sync.caughtGame['counter_001'], isNull);
    });

    test('increment from zero sets startedAt and daily count', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);

      await controller.increment();

      expect(controller.startedAt, isNotNull);
      expect(sync.started['counter_001'], isNotNull);
      expect(sync.daily['counter_001']?[todayKey()], 1);
    });

    test('decrement to zero clears hunt dates and daily counts', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);
      await controller.increment();

      await controller.decrement();

      expect(controller.counter, 0);
      expect(controller.startedAt, isNull);
      expect(controller.caughtAt, isNull);
      expect(sync.started['counter_001'], isNull);
      expect(sync.caughtAt['counter_001'], isNull);
      expect(sync.daily['counter_001'], isEmpty);
    });

    test('setDailyCounts removes non-positive entries', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);
      final day = todayKey();

      await controller.setDailyCounts({day: 3, 'older': 0});

      expect(controller.dailyCounts.containsKey('older'), isFalse);
      expect(controller.dailyCounts[day], 3);
      expect(sync.daily['counter_001']?['older'], isNull);
      expect(sync.daily['counter_001']?[day], 3);
    });

    test('overlay stream updates controller from sync state', () async {
      final sync = FakeCounterSync();
      sync.counters['counter_001'] = 5;
      sync.caught['caught_001'] = true;
      final controller = CounterController(pokemon: pokemon, sync: sync);
      await controller.init();

      sync.emitOverlay('counter:Bulbasaur:counter_001:5:0');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.counter, 5);
      expect(controller.isCaught, isTrue);
    });

    test('overlay closed event clears pillActive', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);
      await controller.init();

      await controller.toggleOverlay(); // activates via fake ensureOverlay
      sync.emitOverlay('closed');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.pillActive, isFalse);
    });

    test(
      'setCaughtAtDate marks caught and persists game when present',
      () async {
        final sync = FakeCounterSync();
        final controller = CounterController(pokemon: pokemon, sync: sync);
        await controller.init();
        controller.setCaughtGame('violet');

        await controller.setCaughtAtDate(DateTime(2024, 1, 1));

        expect(controller.isCaught, isTrue);
        expect(controller.caughtAt, isNotNull);
        expect(sync.caughtAt['counter_001'], isNotNull);
        expect(sync.caughtGame['counter_001'], 'violet');
      },
    );

    test(
      'setStartedAtDate triggers overlay share only when pill active',
      () async {
        final sync = FakeCounterSync();
        final controller = CounterController(pokemon: pokemon, sync: sync);
        await controller.init();

        await controller.setStartedAtDate(DateTime(2024, 1, 2));
        expect(sync.shareCount, 0);

        sync.counters['counter_001'] = 1;
        await controller.toggleOverlay();
        await controller.setStartedAtDate(DateTime(2024, 1, 3));
        expect(sync.shareCount, greaterThan(0));
      },
    );

    test(
      'setCounter with forceUncaught leaves startedAt when count > 0',
      () async {
        final sync = FakeCounterSync();
        final controller = CounterController(pokemon: pokemon, sync: sync);
        await controller.init();
        await controller.increment();
        final startedBefore = controller.startedAt;

        await controller.setCounter(5);

        expect(controller.isCaught, isFalse);
        expect(controller.counter, 5);
        expect(controller.startedAt, startedBefore); // preserved
        expect(sync.caught['caught_001'], isFalse);
      },
    );

    test('toggleCaught at zero sets caughtAt but not startedAt', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);
      await controller.init();

      await controller.toggleCaught();

      expect(controller.isCaught, isTrue);
      expect(controller.caughtAt, isNotNull);
      expect(controller.startedAt, isNull);
    });

    test('overlay message with different counterKey is ignored', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);
      await controller.init();
      controller.setCounterManual(3);

      sync.emitOverlay('counter:Other:counter_999:10:1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.counter, 3);
      expect(controller.isCaught, isFalse);
    });

    test('toggleOverlay when unsupported does nothing', () async {
      final sync = FakeCounterSync();
      final controller = CounterController(pokemon: pokemon, sync: sync);

      await controller.toggleOverlay();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(sync.ensureOverlayCount, greaterThan(0));
    });

    test(
      'setDailyCounts clears zeros and skips overlay when inactive',
      () async {
        final sync = FakeCounterSync();
        final controller = CounterController(pokemon: pokemon, sync: sync);
        await controller.init();

        await controller.setDailyCounts({'2024-01-01': 0});

        expect(sync.daily['counter_001'], isEmpty);
        expect(sync.setDailyCalls, 1);
        expect(sync.shareCount, 0); // overlay not active
      },
    );
  });
}
