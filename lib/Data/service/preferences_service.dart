import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../categories.dart';
import '../models/article_model.dart';

class PreferencesService {
  static const String _interestsKey = 'interests';
  static const String _bookmarksKey = 'bookmarks';
  static const String _darkModeKey = 'darkMode';

  static Future<List<String>> loadInterests() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_interestsKey) ?? allCategories;
  }

  static Future<void> saveInterests(List<String> interests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_interestsKey, interests);
  }

  static Future<List<Article>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_bookmarksKey) ?? [];
    return saved.map((text) => Article.fromJson(jsonDecode(text))).toList();
  }

  static Future<void> saveBookmarks(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final texts = articles.map((article) => jsonEncode(article.toJson())).toList();
    await prefs.setStringList(_bookmarksKey, texts);
  }

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }
}
