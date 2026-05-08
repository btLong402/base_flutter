import 'package:shared_preferences/shared_preferences.dart';

/// Local storage helper using SharedPreferences
class LocalStorage {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception(
        'LocalStorage not initialized. Call LocalStorage.init() first.',
      );
    }
    return _prefs!;
  }

  /// Save string
  static Future<bool> setString(String key, String value) async {
    return instance.setString(key, value);
  }

  /// Get string
  static String? getString(String key) {
    return instance.getString(key);
  }

  /// Save int
  static Future<bool> setInt(String key, int value) async {
    return instance.setInt(key, value);
  }

  /// Get int
  static int? getInt(String key) {
    return instance.getInt(key);
  }

  /// Save double
  static Future<bool> setDouble(String key, double value) async {
    return instance.setDouble(key, value);
  }

  /// Get double
  static double? getDouble(String key) {
    return instance.getDouble(key);
  }

  /// Save bool
  static Future<bool> setBool(String key, {required bool value}) async {
    return instance.setBool(key, value);
  }

  /// Get bool
  static bool? getBool(String key) {
    return instance.getBool(key);
  }

  /// Save string list
  static Future<bool> setStringList(String key, List<String> value) async {
    return instance.setStringList(key, value);
  }

  /// Get string list
  static List<String>? getStringList(String key) {
    return instance.getStringList(key);
  }

  /// Remove key
  static Future<bool> remove(String key) async {
    return instance.remove(key);
  }

  /// Clear all data
  static Future<bool> clear() async {
    return instance.clear();
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return instance.containsKey(key);
  }

  /// Get all keys
  static Set<String> getKeys() {
    return instance.getKeys();
  }
}
