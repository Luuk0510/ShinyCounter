import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/di/app_locator.dart';
import 'core/di/app_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/tokens.dart';
import 'core/theme/theme_notifier.dart';
import 'features/pokemon/overlay/counter_overlay.dart' as counter_overlay;

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
          return MaterialApp.router(
            title: 'Shiny Counter',
            theme: AppTheme.light(),
            darkTheme: theme.useOledDark ? AppTheme.oled() : AppTheme.dark(),
            themeMode: theme.mode,
            routerConfig: router,
            locale: const Locale('nl'),
            supportedLocales: const [
              Locale('nl'),
              Locale('en'),
            ],
            localizationsDelegates: const [
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
