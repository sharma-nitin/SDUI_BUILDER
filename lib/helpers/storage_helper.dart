import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _screensKey = 'saved_screens';

  static Future<void> saveScreens(List<Map<String, dynamic>> screens) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonScreens = jsonEncode(screens);
    await prefs.setString(_screensKey, jsonScreens);
  }

  static Future<List<Map<String, dynamic>>> loadScreens() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonScreens = prefs.getString(_screensKey);
    if (jsonScreens == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(jsonScreens));
  }
}

