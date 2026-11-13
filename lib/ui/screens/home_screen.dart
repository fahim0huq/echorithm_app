import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../../Data/models/article_model.dart';
import '../../Data/service/news_service.dart';
import '../../Data/service/preferences_service.dart';
import '../../Data/urls.dart';
import '../widgets/category_chips.dart';
import '../widgets/error_view.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/news_tile.dart';
import 'detail_screen.dart';
import 'interests_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<String> interests;

  const HomeScreen({super.key, required this.interests});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _service = NewsService();

  late List<String> _interests = widget.interests;
  late String _selectedCategory = _interests.first;
  late Future<List<Article>> _newsFuture;

  List<Article> _articles = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _newsFuture = _fetchFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Article>> _fetchFirstPage() async {
    final articles = await _service.fetchNews(_selectedCategory.toLowerCase());
    _articles = articles;
    _page = 1;
    _hasMore = articles.length == Urls.pageSize;
    return articles;
  }

  void _loadNews() {
    setState(() {
      _newsFuture = _fetchFirstPage();
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final category = _selectedCategory;
    try {
      final newArticles = await _service.fetchNews(category.toLowerCase(), page: _page + 1);
      if (category != _selectedCategory) return;
      setState(() {
        _articles.addAll(newArticles);
        _page++;
        _hasMore = newArticles.length == Urls.pageSize;
      });
    } catch (e) {
      setState(() => _hasMore = false);
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onCategorySelected(String category) {
    _selectedCategory = category;
    _loadNews();
  }

  Future<void> _onRefresh() async {
    _loadNews();
    try {
      await _newsFuture;
    } catch (_) {
    }
  }

  Future<void> _openInterests() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => InterestsScreen(currentInterests: _interests)),
    );
    if (result == null) return;

    await PreferencesService.saveInterests(result);
    _interests = result;
    if (!_interests.contains(_selectedCategory)) {
      _selectedCategory = _interests.first;
    }
    _loadNews();
  }

  void _openDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Echorithm', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(
              _todayText(),
              style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'My Interests',
            onPressed: _openInterests,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          CategoryChips(
            categories: _interests,
            selected: _selectedCategory,
            onSelected: _onCategorySelected,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView();
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Oops! Something went wrong.\n${snapshot.error}',
                    onRetry: _loadNews,
                  );
                }
                if (_articles.isEmpty) {
                  return ErrorView(message: 'No news found.', onRetry: _loadNews);
                }
                return _buildNewsList(_articles);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<Article> articles) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.accent,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: articles.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == articles.length) return _buildFooter();

          final article = articles[index];
          if (index == 0) {
            return FeaturedNewsCard(article: article, onTap: () => _openDetail(article));
          }
          return NewsTile(article: article, onTap: () => _openDetail(article));
        },
      ),
    );
  }

  Widget _buildFooter() {
    if (_hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text("You're all caught up", style: TextStyle(color: AppTheme.textGrey)),
      ),
    );
  }

  String _todayText() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}
