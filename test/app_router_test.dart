import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shiny_counter/core/routing/app_router.dart';

void main() {
  test('app router exposes GoRouter with expected routes', () {
    final router = AppRouter.instance.router;
    expect(router, isA<GoRouter>());
    final routes = router.configuration.routes.whereType<GoRoute>().toList();
    final paths = routes.map((route) => route.path).toList();
    expect(paths, contains(AppRoutes.home));
    expect(paths, contains(AppRoutes.pokemonDetail));
  });
}
