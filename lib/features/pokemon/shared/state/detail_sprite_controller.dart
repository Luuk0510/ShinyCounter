import 'package:flutter/foundation.dart';

class DetailSpriteController extends ChangeNotifier {
  bool _showShiny = true;

  bool get showShiny => _showShiny;

  void toggle({required bool hasNormal}) {
    if (!hasNormal) return;
    _showShiny = !_showShiny;
    notifyListeners();
  }

  void reset() {
    _showShiny = true;
    notifyListeners();
  }
}
