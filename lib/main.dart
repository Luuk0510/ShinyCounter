import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/di/app_locator.dart';
import 'core/di/app_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_notifier.dart';
import 'features/pokemon/overlay/counter_overlay.dart' as counter_overlay;
import 'package:shiny_counter/l10n/gen/app_localizations.dart';
import 'core/l10n/locale_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocator.instance.init();
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void overlayMain() {
  counter_overlay.overlayMain();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.instance.router;
    return MultiProvider(
      providers: buildAppProviders(),
      child: Builder(
        builder: (context) {
          final theme = context.watch<ThemeNotifier>();
          final locale = context.watch<LocaleNotifier>().locale;
          final seedColor = theme.seedColor;
          return MaterialApp.router(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appTitle ?? 'Shiny Counter',
            theme: AppTheme.light(seedColor: seedColor),
            darkTheme: theme.useOledDark
                ? AppTheme.oled(seedColor: seedColor)
                : AppTheme.dark(seedColor: seedColor),
            themeMode: theme.mode,
            routerConfig: router,
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('nl')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
