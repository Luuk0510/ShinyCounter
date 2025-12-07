import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/counter_controller.dart';

import 'helpers/fakes.dart';

void main() {
  const pokemon = Pokemon(
    id: '001',
    name: 'Bulbasaur',
    imagePath: 'assets/001.png',
  );

  group('CounterController', () {
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
  });
}
