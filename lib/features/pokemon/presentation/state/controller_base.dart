import 'package:flutter/foundation.dart';

abstract class ControllerBase extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @protected
  void safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

abstract class LoadableController extends ControllerBase {
  bool _loading = true;

  bool get loading => _loading;

  @protected
  void setLoading(bool value, {bool notify = true}) {
    _loading = value;
    if (notify) {
      safeNotifyListeners();
    }
  }
}
