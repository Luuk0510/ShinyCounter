import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'helpers/fakes.dart';

void main() {
  test('ToggleCaughtUseCase delegates to CounterSync', () async {
    final sync = FakeCounterSync();
    final useCase = ToggleCaughtUseCase(sync);

    await useCase.call('caught_001', true);

    expect(sync.caught['caught_001'], isTrue);
  });
}
