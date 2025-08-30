class RuntimeFlags {
  static bool _lowDataEnabled = false;

  static bool get lowDataEnabled => _lowDataEnabled;
  static void setLowData(bool enabled) {
    _lowDataEnabled = enabled;
  }
}
