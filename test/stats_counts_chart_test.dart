import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/stats/stats_counts_chart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('StatsCountsChart renders line chart', (tester) async {
    final counts = [
      StatsDailyCount(date: DateTime(2024, 1, 1), count: 12),
      StatsDailyCount(date: DateTime(2024, 1, 2), count: 34),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: StatsCountsChart(counts: counts)),
      ),
    );

    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('StatsCountsChart shows custom tooltip on tap', (tester) async {
    final counts = [
      StatsDailyCount(date: DateTime(2024, 1, 1), count: 123),
      StatsDailyCount(date: DateTime(2024, 1, 2), count: 456),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: StatsCountsChart(counts: counts)),
      ),
    );

    final chartFinder = find.byType(LineChart);
    final chartRect = tester.getRect(chartFinder);
    final point = Offset(
      chartRect.left + chartRect.width * 0.1,
      chartRect.center.dy,
    );

    final gesture = await tester.startGesture(point);
    await tester.pump();
    await gesture.moveBy(const Offset(1, 0));
    await tester.pump();

    expect(find.text('123'), findsOneWidget);

    await gesture.up();
    await tester.pump();
  });
}
