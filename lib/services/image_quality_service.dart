import 'package:shared_preferences/shared_preferences.dart';

class ImageQualityService {
  static const String _lowDataKey = 'low_data_mode_enabled';
  static bool _initialized = false;
  static bool _lowDataEnabled = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _lowDataEnabled = prefs.getBool(_lowDataKey) ?? false;
    _initialized = true;
  }

  static bool get isLowDataEnabled => _lowDataEnabled;

  static Future<void> setLowDataEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lowDataKey, enabled);
    _lowDataEnabled = enabled;
  }
}
