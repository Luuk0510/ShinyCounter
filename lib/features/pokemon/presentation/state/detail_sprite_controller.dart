import 'package:shiny_counter/features/pokemon/presentation/state/controller_base.dart';

class DetailSpriteController extends ControllerBase {
  bool _showShiny = true;

  bool get showShiny => _showShiny;

  void toggle({required bool hasNormal}) {
    if (!hasNormal) return;
    _showShiny = !_showShiny;
    safeNotifyListeners();
  }

  void reset() {
    _showShiny = true;
    safeNotifyListeners();
  }
}
