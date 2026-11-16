import 'api_key.dart';

class Urls {
  static const String baseUrl = 'https://newsapi.org/v2';

  static const String apiKey = newsApiKey;

  static const String country = 'us';

  static const int pageSize = 20;

  static const List<int> forYouShares = [15, 10, 5];
}
