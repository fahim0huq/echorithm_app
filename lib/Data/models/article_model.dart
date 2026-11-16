class Article {
  final String title;
  final String sourceName;
  final String? author;
  final String? description;
  final String? content;
  final String url;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String? category;

  Article({
    required this.title,
    required this.sourceName,
    required this.url,
    this.author,
    this.description,
    this.content,
    this.imageUrl,
    this.publishedAt,
    this.category,
  });

  factory Article.fromJson(Map<String, dynamic> json, {String? category}) {
    return Article(
      title: json['title'] ?? 'No title',
      sourceName: json['source']?['name'] ?? 'Unknown',
      author: json['author'],
      description: json['description'],
      content: json['content'],
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? ''),
      category: category ?? json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'source': {'name': sourceName},
      'author': author,
      'description': description,
      'content': content,
      'url': url,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt?.toIso8601String(),
      'category': category,
    };
  }

  String get timeAgo {
    if (publishedAt == null) return '';
    final diff = DateTime.now().difference(publishedAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
