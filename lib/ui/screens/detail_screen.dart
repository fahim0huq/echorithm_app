import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_theme.dart';
import '../../Data/models/article_model.dart';
import '../../Data/service/bookmark_service.dart';
import '../widgets/news_image.dart';

class DetailScreen extends StatelessWidget {
  final Article article;
  final String heroTag;

  const DetailScreen({super.key, required this.article, required this.heroTag});

  static void open(BuildContext context, Article article, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(article: article, heroTag: heroTag),
      ),
    );
  }

  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.parse(article.url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = article.content?.replaceAll(RegExp(r'\[\+\d+ chars\]'), '');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            actions: [
              ValueListenableBuilder<List<Article>>(
                valueListenable: BookmarkService.bookmarks,
                builder: (context, bookmarks, _) {
                  final isSaved = BookmarkService.isSaved(article);
                  return IconButton(
                    icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                    tooltip: isSaved ? 'Remove from saved' : 'Save article',
                    onPressed: () => BookmarkService.toggle(article),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: heroTag,
                child: NewsImage(url: article.imageUrl),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sourceBadge(context),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _authorDateRow(),
                  const SizedBox(height: 20),
                  if (article.description != null)
                    Text(
                      article.description!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 12),
                  if (content != null)
                    Text(content, style: const TextStyle(fontSize: 15, height: 1.6)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openArticle(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Read full article'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourceBadge(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        article.sourceName,
        style: TextStyle(color: primary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _authorDateRow() {
    final date = article.publishedAt;
    final dateText = date == null ? '' : '${date.day}/${date.month}/${date.year}';

    return Row(
      children: [
        const Icon(Icons.person_outline, size: 18, color: AppTheme.textGrey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            article.author ?? 'Unknown author',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textGrey),
          ),
        ),
        const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 4),
        Text(dateText, style: const TextStyle(color: AppTheme.textGrey)),
      ],
    );
  }
}
