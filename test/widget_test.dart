import 'package:daily_news/Data/categories.dart';
import 'package:daily_news/Data/models/article_model.dart';
import 'package:daily_news/Data/service/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Interests default to all categories and can be saved', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await PreferencesService.loadInterests(), allCategories);

    await PreferencesService.saveInterests(['Sports', 'Science']);
    expect(await PreferencesService.loadInterests(), ['Sports', 'Science']);
  });

  test('Article.fromJson handles missing fields', () {
    final article = Article.fromJson({
      'source': {'name': 'BBC'},
      'title': 'Hello',
      'url': 'https://example.com',
    });

    expect(article.sourceName, 'BBC');
    expect(article.imageUrl, isNull);
    expect(article.author, isNull);
    expect(article.timeAgo, '');
  });
}
