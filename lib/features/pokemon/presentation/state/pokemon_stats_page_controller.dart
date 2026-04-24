import 'package:flutter/material.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/counter_state.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/date_range.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/stats_models.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_card_models.dart';
import 'package:shiny_counter/features/pokemon/domain/repositories/stats_repository.dart';
import 'package:shiny_counter/features/pokemon/domain/services/stats_aggregation_service.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/controller_base.dart';

class PokemonStatsPageController extends LoadableController {
  PokemonStatsPageController({required StatsRepository repository})
    : _statsService = StatsAggregationService(repository: repository),
      _chartRange = _buildDefaultChartRange(),
      _cardOrder = List.of(defaultCardOrder);

  static const int defaultChartDays = 30;
  static const List<PokemonStatsCardId> defaultCardOrder = [
    PokemonStatsCardId.caught,
    PokemonStatsCardId.total,
    PokemonStatsCardId.games,
    PokemonStatsCardId.recent,
    PokemonStatsCardId.resetsPokemon,
    PokemonStatsCardId.resetsGame,
    PokemonStatsCardId.history,
  ];

  final StatsAggregationService _statsService;

  DateTimeRange _chartRange;
  List<CounterState> _states = const [];
  StatsSummary _summary = const StatsSummary.empty();
  List<PokemonStatsCardId> _cardOrder;

  DateTimeRange get chartRange => _chartRange;
  List<CounterState> get states => List.unmodifiable(_states);
  StatsSummary get summary => _summary;
  List<PokemonStatsCardId> get cardOrder => List.unmodifiable(_cardOrder);
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
    setLoading(true, notify: false);
    final snapshot = await _statsService.loadStats(
      _domainRangeFromUiRange(_chartRange),
    );
    if (isDisposed) return;
    _states = snapshot.states;
    _summary = snapshot.summary;
    setLoading(false);
  }

  void applyChartRange(DateTimeRange range) {
    _chartRange = range;
    _summary = _statsService.updateSummaryForRange(
      _summary,
      _states,
      _domainRangeFromUiRange(range),
    );
    safeNotifyListeners();
  }

  void resetChartRange() {
    applyChartRange(_buildDefaultChartRange());
  }

  List<PokemonStatsCardId> orderFor(Iterable<PokemonStatsCardId> available) {
    final order = _cardOrder.where(available.contains).toList(growable: true);
    for (final id in available) {
      if (!order.contains(id)) {
        order.add(id);
      }
    }
    return order;
  }

  void setCardOrder(List<PokemonStatsCardId> cardOrder) {
    _cardOrder = List.of(cardOrder);
    safeNotifyListeners();
  }

  List<PokemonStatsCardId> resetOrderFor(
    Iterable<PokemonStatsCardId> available,
  ) {
    return [
      for (final id in defaultCardOrder)
        if (available.contains(id)) id,
      for (final id in available)
        if (!defaultCardOrder.contains(id)) id,
    ];
  }

  List<T> orderedValues<T>(Map<PokemonStatsCardId, T> entries) {
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

  Future<void> initialize() async {
    await loadStats();
  }
}
