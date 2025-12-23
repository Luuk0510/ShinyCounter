import 'package:flutter_test/flutter_test.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/models/pokemon_stats_models.dart';

void main() {
  test('PokemonCaughtEntry stores pokemon and date', () {
    final pokemon = Pokemon(id: '001', name: 'Bulbasaur', imagePath: 'asset');
    final date = DateTime(2024, 1, 1);
    final entry = PokemonCaughtEntry(pokemon, date);

    expect(entry.pokemon, pokemon);
    expect(entry.caughtAt, date);
  });

  test('PokemonGameStatsArgs stores game and items', () {
    final pokemon = Pokemon(id: '002', name: 'Ivysaur', imagePath: 'asset');
    final items = [PokemonCaughtEntry(pokemon, DateTime(2024, 2, 2))];
    final args = PokemonGameStatsArgs(game: 'FireRed', items: items);

    expect(args.game, 'FireRed');
    expect(args.items, items);
  });

  test('StatsDailyCount stores date and count', () {
    final date = DateTime(2024, 3, 3);
    const count = 42;
    final daily = StatsDailyCount(date: date, count: count);

    expect(daily.date, date);
    expect(daily.count, count);
  });
}
