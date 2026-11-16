import 'package:flutter/material.dart';

import '../../Data/models/article_model.dart';
import '../../Data/service/bookmark_service.dart';
import '../utils/app_theme.dart';
import '../widgets/news_tile.dart';
import 'detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  void _remove(BuildContext context, Article article) {
    BookmarkService.toggle(article);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from saved'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => BookmarkService.toggle(article),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ValueListenableBuilder<List<Article>>(
        valueListenable: BookmarkService.bookmarks,
        builder: (context, bookmarks, _) {
          if (bookmarks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 64, color: AppTheme.textGrey),
                  SizedBox(height: 12),
                  Text('No saved articles yet', style: TextStyle(color: AppTheme.textGrey)),
                  SizedBox(height: 4),
                  Text('Tap the bookmark icon on any article',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final article = bookmarks[index];
              final heroTag = 'saved-$index';
              return Dismissible(
                key: ValueKey(article.url),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _remove(context, article),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: NewsTile(
                  article: article,
                  heroTag: heroTag,
                  onTap: () => DetailScreen.open(context, article, heroTag),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
