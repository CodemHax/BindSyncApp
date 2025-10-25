import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String username_key = 'user_username';
  static const String api_base_url_key = 'api_base_url';
  static const String default_api_url = 'https://bindsyncv2.onrender.com';

  Future<String?> get_username() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(username_key);
  }

  Future<void> set_username(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(username_key, username);
  }

  Future<String> get_api_base_url() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(api_base_url_key) ?? default_api_url;
  }

  Future<void> set_api_base_url(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(api_base_url_key, url);
  }

  Future<void> clear_preferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
