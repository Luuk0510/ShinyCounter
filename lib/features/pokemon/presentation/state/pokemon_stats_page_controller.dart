import 'package:flutter/material.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/counter_state.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/date_range.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/stats_models.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/stats_aggregation_service.dart';

enum StatsCardId {
  caught,
  total,
  games,
  recent,
  resetsPokemon,
  resetsGame,
  history,
}

class PokemonStatsPageController extends ChangeNotifier {
  PokemonStatsPageController({required StatsRepository repository})
    : _statsService = StatsAggregationService(repository: repository),
      _chartRange = _buildDefaultChartRange(),
      _cardOrder = List.of(defaultCardOrder);

  static const int defaultChartDays = 30;
  static const List<StatsCardId> defaultCardOrder = [
    StatsCardId.caught,
    StatsCardId.total,
    StatsCardId.games,
    StatsCardId.recent,
    StatsCardId.resetsPokemon,
    StatsCardId.resetsGame,
    StatsCardId.history,
  ];

  final StatsAggregationService _statsService;

  DateTimeRange _chartRange;
  List<CounterState> _states = const [];
  bool _loading = true;
  StatsSummary _summary = const StatsSummary.empty();
  List<StatsCardId> _cardOrder;
  bool _disposed = false;

  DateTimeRange get chartRange => _chartRange;
  List<CounterState> get states => List.unmodifiable(_states);
  bool get loading => _loading;
  StatsSummary get summary => _summary;
  List<StatsCardId> get cardOrder => List.unmodifiable(_cardOrder);
  DateTime get lastSelectableDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get firstSelectableDate => DateTime(
    lastSelectableDate.year - 1,
    lastSelectableDate.month,
    lastSelectableDate.day,
  );

  Future<void> loadStats() async {
    final snapshot = await _statsService.loadStats(
      _domainRangeFromUiRange(_chartRange),
    );
    if (_disposed) return;
    _states = snapshot.states;
    _summary = snapshot.summary;
    _loading = false;
    _safeNotify();
  }

  void applyChartRange(DateTimeRange range) {
    _chartRange = range;
    _summary = _statsService.updateSummaryForRange(
      _summary,
      _states,
      _domainRangeFromUiRange(range),
    );
    _safeNotify();
  }

  void resetChartRange() {
    applyChartRange(_buildDefaultChartRange());
  }

  List<StatsCardId> orderFor(Iterable<StatsCardId> available) {
    final order = _cardOrder.where(available.contains).toList(growable: true);
    for (final id in available) {
      if (!order.contains(id)) {
        order.add(id);
      }
    }
    return order;
  }

  void setCardOrder(List<StatsCardId> cardOrder) {
    _cardOrder = List.of(cardOrder);
    _safeNotify();
  }

  List<StatsCardId> resetOrderFor(Iterable<StatsCardId> available) {
    return [
      for (final id in defaultCardOrder)
        if (available.contains(id)) id,
      for (final id in available)
        if (!defaultCardOrder.contains(id)) id,
    ];
  }

  List<T> orderedValues<T>(Map<StatsCardId, T> entries) {
    return [for (final id in orderFor(entries.keys)) entries[id]!];
  }

  DateRange _domainRangeFromUiRange(DateTimeRange range) {
    return DateRange(start: range.start, end: range.end);
  }

  static DateTimeRange _buildDefaultChartRange() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(const Duration(days: defaultChartDays - 1));
    return DateTimeRange(start: start, end: end);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }
}
