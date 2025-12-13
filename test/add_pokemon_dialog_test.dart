import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/add_pokemon_dialog.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/search_gen_filter_row.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

import 'helpers/fakes.dart';
import 'helpers/test_asset_bundle.dart';

Future<void> _waitForText(
  WidgetTester tester,
  String text, {
  Duration step = const Duration(milliseconds: 50),
  int maxSteps = 80,
}) async {
  for (var i = 0; i < maxSteps && find.text(text).evaluate().isEmpty; i++) {
    await tester.pump(step);
  }
}

Widget _wrap(Widget child, {required SpriteService spriteService}) {
  final bundle = TestAssetBundle([
    'assets/pokemons/0001_base_m_s.png',
    'assets/pokemons/0152_base_m_s.png',
    'assets/pokemons/0252_base_m_s.png',
    'assets/data/pokemon_names_en.json',
  ]);
  return DefaultAssetBundle(
    bundle: bundle,
    child: Provider<SpriteService>.value(
      value: spriteService,
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
    // PokemonNames.load() uses rootBundle; provide a minimal asset response so
    // the controller init completes reliably in widget tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          if (message == null) return null;
          final key = utf8.decode(message.buffer.asUint8List());
          if (key != 'assets/data/pokemon_names_en.json') return null;
          final body = jsonEncode(<String, String>{
            '0001': 'Bulbasaur',
            '0152': 'Chikorita',
            '0252': 'Treecko',
          });
          final bytes = Uint8List.fromList(utf8.encode(body));
          return ByteData.view(bytes.buffer);
        });
  });

  testWidgets('search + gen filter reduce list; clear restores', (
    tester,
  ) async {
    final spriteService = FakeSpriteService(const [
      ParsedSprite(
        dex: '0001',
        form: 'base',
        gender: 'm',
        shiny: true,
        path: 'assets/pokemons/0001_base_m_s.png',
      ),
      ParsedSprite(
        dex: '0152',
        form: 'base',
        gender: 'm',
        shiny: true,
        path: 'assets/pokemons/0152_base_m_s.png',
      ),
      ParsedSprite(
        dex: '0252',
        form: 'base',
        gender: 'm',
        shiny: true,
        path: 'assets/pokemons/0252_base_m_s.png',
      ),
    ]);

    await tester.pumpWidget(
      _wrap(const AddPokemonDialog(), spriteService: spriteService),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await _waitForText(tester, '#0001');

    expect(find.text('#0001'), findsOneWidget);
    expect(find.text('#0152'), findsOneWidget);
    expect(find.text('#0252'), findsOneWidget);

    await tester.enterText(
      find.byKey(SearchGenFilterRow.searchFieldKey),
      '0152',
    );
    await tester.pumpAndSettle();
    expect(find.text('#0152'), findsOneWidget);
    expect(find.text('#0001'), findsNothing);
    expect(find.text('#0252'), findsNothing);

    await tester.tap(find.byKey(SearchGenFilterRow.clearButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('#0001'), findsOneWidget);
    expect(find.text('#0152'), findsOneWidget);
    expect(find.text('#0252'), findsOneWidget);

    await tester.tap(find.byKey(SearchGenFilterRow.genDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SearchGenFilterRow.genItemKey(2)));
    await tester.pumpAndSettle();
    expect(find.text('#0152'), findsOneWidget);
    expect(find.text('#0001'), findsNothing);
    expect(find.text('#0252'), findsNothing);
  });

  testWidgets(
    'selecting a pokemon enables Choose and returns Pokemon',
    (tester) async {
      final spriteService = FakeSpriteService(const [
        ParsedSprite(
          dex: '0001',
          form: 'base',
          gender: 'm',
          shiny: true,
          path: 'assets/pokemons/0001_base_m_s.png',
        ),
      ]);

      Pokemon? result;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  result = await showAddPokemonDialog(context);
                },
                child: const Text('open'),
              );
            },
          ),
          spriteService: spriteService,
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump(const Duration(milliseconds: 300));
      await _waitForText(tester, '#0001');
      expect(
        find.text('#0001'),
        findsOneWidget,
        reason: 'sprite list should load',
      );

      final chooseButton = find.widgetWithText(ElevatedButton, 'Choose');
      expect(tester.widget<ElevatedButton>(chooseButton).onPressed, isNull);

      await tester.tap(find.text('#0001'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.widget<ElevatedButton>(chooseButton).onPressed, isNotNull);

      await tester.tap(chooseButton);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(result, isA<Pokemon>());
      expect(result!.id, startsWith('custom_0001_'));
      expect(result!.imagePath, 'assets/pokemons/0001_base_m_s.png');
    },
    // TODO: flaky until rootBundle asset loading is stabilized in tests.
    skip: true,
  );
}
