import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../../Data/models/article_model.dart';
import '../../Data/service/news_service.dart';
import '../../Data/service/personalization_service.dart';
import '../../Data/service/preferences_service.dart';
import '../../Data/urls.dart';
import '../widgets/category_chips.dart';
import '../widgets/error_view.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/for_you_header.dart';
import '../widgets/loading_view.dart';
import '../widgets/news_tile.dart';
import 'detail_screen.dart';
import 'interests_screen.dart';

const String forYou = 'For You';

class HomeScreen extends StatefulWidget {
  final List<String> interests;
  final bool isFirstLaunch;

  const HomeScreen({super.key, required this.interests, this.isFirstLaunch = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _service = NewsService();

  late List<String> _interests = widget.interests;
  String _selectedCategory = forYou;
  List<String> _forYouTopics = [];
  late Future<List<Article>> _newsFuture;

  List<Article> _articles = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  bool get _isForYou => _selectedCategory == forYou;

  @override
  void initState() {
    super.initState();
    _newsFuture = _fetchFirstPage();
    _scrollController.addListener(_onScroll);

    if (widget.isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openInterests(isWelcome: true));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Article>> _fetchPage(int page) {
    if (_isForYou) {
      _forYouTopics = PersonalizationService.topTopics(_interests);
      return _service.fetchForYou(_forYouTopics, page: page);
    }
    return _service.fetchNews(_selectedCategory, page: page);
  }

  bool _isFullPage(List<Article> articles) {
    if (_isForYou) {
      final expected = Urls.forYouShares
          .take(_forYouTopics.length)
          .fold(0, (total, share) => total + share);
      return articles.length >= expected ~/ 2;
    }
    return articles.length == Urls.pageSize;
  }

  Future<List<Article>> _fetchFirstPage() async {
    final articles = await _fetchPage(1);
    _articles = articles;
    _page = 1;
    _hasMore = _isFullPage(articles);
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
      final newArticles = await _fetchPage(_page + 1);
      if (category != _selectedCategory) return;
      final knownUrls = _articles.map((article) => article.url).toSet();
      setState(() {
        _articles.addAll(newArticles.where((article) => !knownUrls.contains(article.url)));
        _page++;
        _hasMore = _isFullPage(newArticles);
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

  Future<void> _openInterests({bool isWelcome = false}) async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => InterestsScreen(currentInterests: _interests, isWelcome: isWelcome),
      ),
    );
    if (result == null) return;

    await PreferencesService.saveInterests(result);
    _interests = result;
    if (!_isForYou && !_interests.contains(_selectedCategory)) {
      _selectedCategory = forYou;
    }
    _loadNews();
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
            categories: [forYou, ..._interests],
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
    final headerCount = _isForYou ? 1 : 0;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.accent,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: headerCount + articles.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (_isForYou && index == 0) return ForYouHeader(topics: _forYouTopics);

          final position = index - headerCount;
          if (position == articles.length) return _buildFooter();

          final article = articles[position];
          final heroTag = 'home-$position';
          void openDetail() => DetailScreen.open(context, article, heroTag);

          if (position == 0) {
            return FeaturedNewsCard(article: article, heroTag: heroTag, onTap: openDetail);
          }
          return NewsTile(article: article, heroTag: heroTag, onTap: openDetail);
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
