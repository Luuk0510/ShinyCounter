import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../theme/theme_notifier.dart';
import '../l10n/locale_notifier.dart';
import '../../features/pokemon/domain/repositories/pokemon_repository.dart';
import '../../features/pokemon/domain/services/counter_sync.dart';
import '../../features/pokemon/shared/services/sprite_service.dart';
import '../di/app_locator.dart';

List<SingleChildWidget> buildAppProviders() {
  return [
    ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
    ChangeNotifierProvider<LocaleNotifier>(create: (_) => LocaleNotifier()),
    Provider<PokemonRepository>.value(
      value: AppLocator.instance.pokemonRepository,
    ),
    Provider<CounterSync>.value(value: AppLocator.instance.counterSyncService),
    Provider.value(value: AppLocator.instance.loadCustomPokemon),
    Provider.value(value: AppLocator.instance.saveCustomPokemon),
    Provider.value(value: AppLocator.instance.loadCaught),
    Provider.value(value: AppLocator.instance.toggleCaught),
    Provider<SpriteService>.value(value: AppLocator.instance.spriteRepository),
  ];
}
