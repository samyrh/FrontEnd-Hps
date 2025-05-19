import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyLastUsername = 'remembered_username';
  static const _keyUserList = 'past_usernames';

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();

    // Save last used username
    await prefs.setString(_keyLastUsername, username);

    // Save to list of usernames
    List<String> pastUsers = prefs.getStringList(_keyUserList) ?? [];
    if (!pastUsers.contains(username)) {
      pastUsers.add(username);
      await prefs.setStringList(_keyUserList, pastUsers);
    }
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastUsername);
  }

  static Future<List<String>> getPastUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyUserList) ?? [];
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    // Note: we intentionally don't clear remembered_username or past_usernames
  }

  static Future<void> clearAllUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserList);
    await prefs.remove(_keyLastUsername);
  }
}

