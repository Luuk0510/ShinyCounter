import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/services/counter_sync.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/toggle_caught.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_detail_page.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/l10n/app_localizations.dart';

import 'helpers/fakes.dart';
import 'helpers/test_asset_bundle.dart';

Widget _wrap(
  Widget child, {
  required CounterSync sync,
  required SpriteService spriteService,
}) {
  final bundle = TestAssetBundle([
    'assets/pokemons/0001_base_m_s.png',
    'assets/pokemons/0001_mega-x_m_s.png',
    'assets/pokemons/0001_001-gmax_m_s.png',
    'assets/pokemons/0001_base_m_n.png',
    'assets/pokemons/0001_mega-x_m_n.png',
    'assets/pokemons/0001_001-gmax_m_n.png',
  ]);
  return DefaultAssetBundle(
    bundle: bundle,
    child: MultiProvider(
      providers: [
        Provider<CounterSync>.value(value: sync),
        Provider<ToggleCaughtUseCase?>.value(value: null),
        Provider<SpriteService>.value(value: spriteService),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') return null;
          return null;
        });
  });

  testWidgets('counter +/- disabled when caught', (tester) async {
    final sync = FakeCounterSync();
    sync.counters['counter_0001'] = 5;
    sync.caught['caught_0001'] = true;

    final spriteService = FakeSpriteService(const [
      ParsedSprite(
        dex: '0001',
        form: 'base',
        gender: 'm',
        shiny: true,
        path: 'assets/pokemons/0001_base_m_s.png',
      ),
      ParsedSprite(
        dex: '0001',
        form: 'base',
        gender: 'm',
        shiny: false,
        path: 'assets/pokemons/0001_base_m_n.png',
      ),
    ]);

    const pokemon = Pokemon(
      id: '0001',
      name: 'Bulbasaur',
      imagePath: 'assets/pokemons/0001_base_m_s.png',
    );

    await tester.pumpWidget(
      _wrap(
        PokemonDetailPage(pokemon: pokemon),
        sync: sync,
        spriteService: spriteService,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    for (
      var i = 0;
      i < 80 && find.byKey(const Key('detail.catchButton')).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final addButton = find.widgetWithIcon(ElevatedButton, Icons.add);
    final removeButton = find.widgetWithIcon(ElevatedButton, Icons.remove);
    expect(tester.widget<ElevatedButton>(addButton).onPressed, isNull);
    expect(tester.widget<ElevatedButton>(removeButton).onPressed, isNull);
    final catchButton = find.byKey(const Key('detail.catchButton'));
    expect(
      find.descendant(of: catchButton, matching: find.text('Caught')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Catch toggles to Caught and disables increment',
    (tester) async {
      final sync = FakeCounterSync();
      sync.counters['counter_0001'] = 0;
      sync.caught['caught_0001'] = false;

      final spriteService = FakeSpriteService(const [
        ParsedSprite(
          dex: '0001',
          form: 'base',
          gender: 'm',
          shiny: true,
          path: 'assets/pokemons/0001_base_m_s.png',
        ),
        ParsedSprite(
          dex: '0001',
          form: 'mega-x',
          gender: 'm',
          shiny: true,
          path: 'assets/pokemons/0001_mega-x_m_s.png',
        ),
        ParsedSprite(
          dex: '0001',
          form: '001-gmax',
          gender: 'm',
          shiny: true,
          path: 'assets/pokemons/0001_001-gmax_m_s.png',
        ),
        ParsedSprite(
          dex: '0001',
          form: 'base',
          gender: 'm',
          shiny: false,
          path: 'assets/pokemons/0001_base_m_n.png',
        ),
        ParsedSprite(
          dex: '0001',
          form: 'mega-x',
          gender: 'm',
          shiny: false,
          path: 'assets/pokemons/0001_mega-x_m_n.png',
        ),
        ParsedSprite(
          dex: '0001',
          form: '001-gmax',
          gender: 'm',
          shiny: false,
          path: 'assets/pokemons/0001_001-gmax_m_n.png',
        ),
      ]);

      const pokemon = Pokemon(
        id: '0001',
        name: 'Bulbasaur',
        imagePath: 'assets/pokemons/0001_base_m_s.png',
      );

      await tester.pumpWidget(
        _wrap(
          PokemonDetailPage(pokemon: pokemon),
          sync: sync,
          spriteService: spriteService,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      for (
        var i = 0;
        i < 80 &&
            find.byKey(const Key('detail.catchButton')).evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Ordering: base should be first rendered.
      expect(
        find.byKey(const ValueKey('assets/pokemons/0001_base_m_s.png')),
        findsOneWidget,
      );

      // Swipe to mega then gmax.
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('assets/pokemons/0001_mega-x_m_s.png')),
        findsOneWidget,
      );

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('assets/pokemons/0001_001-gmax_m_s.png')),
        findsOneWidget,
      );

      // Catch toggle updates text and disables increment.
      final catchButton = find.byKey(const Key('detail.catchButton'));
      expect(
        find.descendant(of: catchButton, matching: find.text('Catch')),
        findsOneWidget,
      );
      await tester.tap(catchButton);
      await tester.pump(); // process tap -> schedules delayed toggle
      await tester.pump(const Duration(milliseconds: 200)); // press+toggle delay
      await tester.pumpAndSettle();
      for (
        var i = 0;
        i < 80 &&
            sync.caught['caught_0001'] != true;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(sync.caught['caught_0001'], isTrue);
      await tester.pump();
      expect(
        find.descendant(
          of: catchButton,
          matching: find.byKey(const ValueKey(true)),
        ),
        findsOneWidget,
      );

      final addButton = find.widgetWithIcon(ElevatedButton, Icons.add);
      expect(tester.widget<ElevatedButton>(addButton).onPressed, isNull);
    },
  );
}
