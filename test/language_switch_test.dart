import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny_counter/core/l10n/locale_notifier.dart';
import 'package:shiny_counter/core/theme/theme_notifier.dart';
import 'package:shiny_counter/features/pokemon/data/repositories/prefs_pokemon_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_caught.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/load_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/domain/usecases/save_custom_pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/pages/pokemon_list_page.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class _EmptyRepo extends PrefsPokemonRepository {
  @override
  Future<List<Pokemon>> loadCustomPokemon() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('language switch updates app bar title', (tester) async {
    final repo = _EmptyRepo();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<LoadCustomPokemonUseCase>(
            create: (_) => LoadCustomPokemonUseCase(repo),
          ),
          Provider<SaveCustomPokemonUseCase>(
            create: (_) => SaveCustomPokemonUseCase(repo),
          ),
          Provider<LoadCaughtUseCase>(create: (_) => LoadCaughtUseCase(repo)),
          Provider<SpriteService>.value(value: SpriteRepository()),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('en'), Locale('nl')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PokemonListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open settings dialog.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    // Switch to Dutch.
    await tester.tap(find.text('Nederlands'));
    await tester.pumpAndSettle();

    // Close dialog.
    await tester.tap(find.textContaining('Cancel'));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(PokemonListPage));
    final locale = ctx.read<LocaleNotifier>().locale;
    expect(locale?.languageCode, 'nl');
  });
}
