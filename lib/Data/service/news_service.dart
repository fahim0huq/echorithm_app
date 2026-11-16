import 'dart:convert';

import 'package:http/http.dart' as http;

import '../urls.dart';
import '../models/article_model.dart';

class NewsService {
  Future<List<Article>> fetchNews(
    String category, {
    int page = 1,
    int pageSize = Urls.pageSize,
  }) {
    return _getArticles(
      '/top-headlines',
      {
        'country': Urls.country,
        'category': category.toLowerCase(),
        'pageSize': '$pageSize',
        'page': '$page',
      },
      category: category,
    );
  }

  Future<List<Article>> fetchForYou(List<String> topics, {int page = 1}) async {
    final results = await Future.wait(
      List.generate(topics.length, (rank) {
        return fetchNews(topics[rank], page: page, pageSize: Urls.forYouShares[rank]);
      }),
    );

    final seenUrls = <String>{};
    final mixed = results
        .expand((articles) => articles)
        .where((article) => seenUrls.add(article.url))
        .toList();

    mixed.sort((a, b) {
      final dateA = a.publishedAt ?? DateTime(2000);
      final dateB = b.publishedAt ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });
    return mixed;
  }

  Future<List<Article>> searchNews(String query) {
    return _getArticles('/everything', {
      'q': query,
      'language': 'en',
      'sortBy': 'relevancy',
      'pageSize': '${Urls.pageSize}',
    });
  }

  Future<List<Article>> _getArticles(
    String path,
    Map<String, String> params, {
    String? category,
  }) async {
    final url = Uri.parse('${Urls.baseUrl}$path').replace(
      queryParameters: {...params, 'apiKey': Urls.apiKey},
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Could not load news (error ${response.statusCode}).');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> articlesJson = data['articles'] ?? [];

    return articlesJson
        .map((json) => Article.fromJson(json, category: category))
        .where((article) => article.title != '[Removed]')
        .toList();
  }
}
