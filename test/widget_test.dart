import 'package:daily_news/Data/categories.dart';
import 'package:daily_news/Data/models/article_model.dart';
import 'package:daily_news/Data/service/personalization_service.dart';
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

  test('Bookmarks and dark mode are saved and loaded back', () async {
    SharedPreferences.setMockInitialValues({});
    final article = Article.fromJson({
      'source': {'name': 'BBC'},
      'title': 'Saved story',
      'url': 'https://example.com/a',
      'publishedAt': '2026-11-10T08:00:00Z',
    });

    await PreferencesService.saveBookmarks([article]);
    final loaded = await PreferencesService.loadBookmarks();
    expect(loaded.single.title, 'Saved story');
    expect(loaded.single.sourceName, 'BBC');
    expect(loaded.single.publishedAt, article.publishedAt);

    expect(await PreferencesService.loadDarkMode(), false);
    await PreferencesService.saveDarkMode(true);
    expect(await PreferencesService.loadDarkMode(), true);
  });

  test('For You puts the most-read topics first', () async {
    SharedPreferences.setMockInitialValues({});
    await PersonalizationService.load();
    final interests = ['Business', 'Technology', 'Sports', 'Health'];

    expect(PersonalizationService.topTopics(interests), ['Business', 'Technology', 'Sports']);

    final sportsStory = Article.fromJson({'title': 'Goal', 'url': 'u1'}, category: 'Sports');
    final healthStory = Article.fromJson({'title': 'Sleep', 'url': 'u2'}, category: 'Health');
    await PersonalizationService.recordRead(sportsStory);
    await PersonalizationService.recordRead(sportsStory);
    await PersonalizationService.recordRead(healthStory);

    expect(PersonalizationService.topTopics(interests), ['Sports', 'Health', 'Business']);

    await PersonalizationService.load();
    expect(PersonalizationService.readCount('Sports'), 2);
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
