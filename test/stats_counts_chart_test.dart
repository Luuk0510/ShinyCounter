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
    final center = tester.getCenter(chartFinder);
    await tester.tapAt(center);
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_StatsChartTooltip',
      ),
      findsOneWidget,
    );
  });
}
