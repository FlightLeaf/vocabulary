import 'package:shared_preferences/shared_preferences.dart';

class DataUtils {
  static late final SharedPreferences _spf;

  static Future<void> init() async {
    _spf = await SharedPreferences.getInstance();
  }

  static bool hasKey(String key) => _spf.getKeys().contains(key);

  static Set<String> getKeys() => _spf.getKeys();

  static dynamic get(String key) => _spf.get(key);

  static String? getString(String key) => _spf.getString(key);

  static void putString(String key, String value) => _spf.setString(key, value);

  static bool? getBool(String key) => _spf.getBool(key);

  static void putBool(String key, bool value) => _spf.setBool(key, value);

  static int? getInt(String key) => _spf.getInt(key);

  static void putInt(String key, int value) => _spf.setInt(key, value);

  static double? getDouble(String key) => _spf.getDouble(key);

  static void putDouble(String key, double value) => _spf.setDouble(key, value);

  static List<String>? getStringList(String key) => _spf.getStringList(key);

  static void putStringList(String key, List<String> value) =>
      _spf.setStringList(key, value);

  static dynamic getDynamic(String key) => _spf.get(key);

  static Future<bool> saveThemeColorIndex(int value) =>
      _spf.setInt('key_theme_color', value);

  static int getThemeColorIndex() =>
      _spf.getInt('key_theme_color') ?? 0;

  static void remove(String key) => _spf.remove(key);

  static void clear() => _spf.clear();
}
