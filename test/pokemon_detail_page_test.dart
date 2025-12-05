import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/features/pokemon/data/datasources/counter_sync_service.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_detail_page.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('catch button toggles to caught and disables controls', (
    tester,
  ) async {
    final sync = await CounterSyncService.instance();
    final pokemon = const Pokemon(
      id: 'p-eevee',
      name: 'Eevee',
      imagePath: 'assets/icon/pokeball_icon.png',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: sync),
          Provider.value(value: ToggleCaughtUseCase(sync)),
          Provider<SpriteService>.value(value: SpriteRepository()),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('nl')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PokemonDetailPage(pokemon: pokemon),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap catch button.
    // Tap the main catch button (ignore the hint text in hunt card).
    final catchButton = find.byKey(const Key('catch_button'));
    await tester.tap(catchButton);
    await tester.pumpAndSettle();

    // Button text should update to the caught label.
    expect(
      find.descendant(
        of: catchButton,
        matching: find.byWidgetPredicate(
          (w) => w is Text && (w.data == 'Caught' || w.data == 'Gevangen'),
        ),
      ),
      findsOneWidget,
    );

    // Plus/minus controls should be disabled.
    final addButton = tester.widget<ElevatedButton>(
      find.widgetWithIcon(ElevatedButton, Icons.add),
    );
    final removeButton = tester.widget<ElevatedButton>(
      find.widgetWithIcon(ElevatedButton, Icons.remove),
    );
    expect(addButton.onPressed, isNull);
    expect(removeButton.onPressed, isNull);
  });
}
