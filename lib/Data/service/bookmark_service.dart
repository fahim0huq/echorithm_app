import 'package:flutter/foundation.dart';

import '../models/article_model.dart';
import 'preferences_service.dart';

class BookmarkService {
  static final ValueNotifier<List<Article>> bookmarks = ValueNotifier([]);

  static Future<void> load() async {
    bookmarks.value = await PreferencesService.loadBookmarks();
  }

  static bool isSaved(Article article) {
    return bookmarks.value.any((saved) => saved.url == article.url);
  }

  static Future<void> toggle(Article article) async {
    final list = [...bookmarks.value];
    if (isSaved(article)) {
      list.removeWhere((saved) => saved.url == article.url);
    } else {
      list.insert(0, article);
    }
    bookmarks.value = list;
    await PreferencesService.saveBookmarks(list);
  }
}
