import 'dart:convert';

import 'package:http/http.dart' as http;

import '../urls.dart';
import '../models/article_model.dart';

class NewsService {
  Future<List<Article>> fetchNews(String category, {int page = 1}) {
    return _getArticles('/top-headlines', {
      'country': Urls.country,
      'category': category,
      'pageSize': '${Urls.pageSize}',
      'page': '$page',
    });
  }

  Future<List<Article>> searchNews(String query) {
    return _getArticles('/everything', {
      'q': query,
      'language': 'en',
      'sortBy': 'relevancy',
      'pageSize': '${Urls.pageSize}',
    });
  }

  Future<List<Article>> _getArticles(String path, Map<String, String> params) async {
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
        .map((json) => Article.fromJson(json))
        .where((article) => article.title != '[Removed]')
        .toList();
  }
}
