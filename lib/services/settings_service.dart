import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _baseUrlKey = 'base_url';
  static const String _defaultBaseUrl = 'http://192.168.1.21/jardin_enfant_ghofrane';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, baseUrl);
  }

  static Future<void> resetToDefault() async {
    await setBaseUrl(_defaultBaseUrl);
  }

  static String getDefaultBaseUrl() {
    return _defaultBaseUrl;
  }
}
