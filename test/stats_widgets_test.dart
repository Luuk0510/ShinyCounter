import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/responsive_text_row.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_app_bar.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_expandable_section.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_row.dart';
import 'package:shiny_counter/l10n/gen/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('StatsCard renders title and child', (tester) async {
    await tester.pumpWidget(
      _wrap(const StatsCard(title: 'Totals', child: Text('42'))),
    );

    expect(find.text('Totals'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('StatsAppBar renders centered title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: const StatsAppBar(title: Text('Stats'))),
      ),
    );

    expect(find.text('Stats'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('StatsRow uses InkWell when tappable', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StatsRow(
          leading: const Icon(Icons.star),
          title: 'Game',
          trailing: '3',
          trailingWidth: 40,
          maxWidth: 200,
          onTap: () {},
        ),
      ),
    );

    expect(find.byType(InkWell), findsOneWidget);
    expect(find.text('Game'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('ResponsiveTextRow stacks on narrow width', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 120,
          child: ResponsiveTextRow(
            key: const Key('responsive'),
            leading: const Icon(Icons.check),
            title: 'Bulbasaur',
            trailing: '01-01-2024',
            trailingWidth: 120,
            maxWidth: 200,
            stackOnNarrow: true,
            stackThreshold: 1.0,
          ),
        ),
      ),
    );

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('01-01-2024'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('responsive')),
        matching: find.byType(Column),
      ),
      findsOneWidget,
    );
  });

  testWidgets('StatsExpandableSection toggles show all/less', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StatsExpandableSection(
          itemCount: 5,
          builder: (visibleCount) => Column(
            children: [for (var i = 0; i < visibleCount; i++) Text('Item $i')],
          ),
        ),
      ),
    );

    expect(find.text('Show all'), findsOneWidget);
    expect(find.text('Item 4'), findsNothing);

    await tester.tap(find.text('Show all'));
    await tester.pumpAndSettle();

    expect(find.text('Show less'), findsOneWidget);
    expect(find.text('Item 4'), findsOneWidget);
  });
}
