import '../models/article_model.dart';
import '../urls.dart';
import 'preferences_service.dart';

class PersonalizationService {
  static Map<String, int> _readCounts = {};

  static Future<void> load() async {
    _readCounts = await PreferencesService.loadReadCounts();
  }

  static int readCount(String topic) => _readCounts[topic] ?? 0;

  static Future<void> recordRead(Article article) async {
    final topic = article.category;
    if (topic == null) return;
    _readCounts[topic] = readCount(topic) + 1;
    await PreferencesService.saveReadCounts(_readCounts);
  }

  static List<String> topTopics(List<String> interests) {
    final sorted = [...interests];
    sorted.sort((a, b) {
      final byReads = readCount(b).compareTo(readCount(a));
      if (byReads != 0) return byReads;
      return interests.indexOf(a).compareTo(interests.indexOf(b));
    });
    return sorted.take(Urls.forYouShares.length).toList();
  }
}
