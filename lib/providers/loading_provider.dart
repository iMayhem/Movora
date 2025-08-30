import 'package:flutter/foundation.dart';

class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void show() {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
  }

  void hide() {
    if (!_isLoading) return;
    _isLoading = false;
    notifyListeners();
  }
}
