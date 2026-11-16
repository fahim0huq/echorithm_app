import 'dart:async';

import 'package:flutter/material.dart';

import '../../Data/models/article_model.dart';
import '../../Data/service/news_service.dart';
import '../utils/app_theme.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/news_tile.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final NewsService _service = NewsService();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  Future<List<Article>>? _searchFuture;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(text));
  }

  void _search(String text) {
    _debounce?.cancel();
    final query = text.trim();
    if (query == _query && _searchFuture != null) return;

    setState(() {
      _query = query;
      _searchFuture = query.isEmpty ? null : _service.searchNews(query);
    });
  }

  void _clear() {
    _controller.clear();
    _search('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search news, e.g. "climate"',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(icon: const Icon(Icons.close), onPressed: _clear),
                ),
                filled: true,
                fillColor: AppTheme.cardColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchFuture == null) {
      return const _SearchHint();
    }

    return FutureBuilder<List<Article>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Oops! Something went wrong.\n${snapshot.error}',
            onRetry: () => setState(() => _searchFuture = _service.searchNews(_query)),
          );
        }
        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return Center(
            child: Text(
              'No results for "$_query"',
              style: const TextStyle(color: AppTheme.textGrey),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final article = articles[index];
            final heroTag = 'search-$index';
            return NewsTile(
              article: article,
              heroTag: heroTag,
              onTap: () => DetailScreen.open(context, article, heroTag),
            );
          },
        );
      },
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_search_rounded, size: 64, color: AppTheme.textGrey),
          SizedBox(height: 12),
          Text('Type something to search the news',
              style: TextStyle(color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}
