import 'package:shared_preferences/shared_preferences.dart';

import '../categories.dart';

class PreferencesService {
  static const String _key = 'interests';

  static Future<List<String>> loadInterests() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? allCategories;
  }

  static Future<void> saveInterests(List<String> interests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, interests);
  }
}
