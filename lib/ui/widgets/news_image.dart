import 'package:flutter/material.dart';

class NewsImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;

  const NewsImage({super.key, required this.url, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder(showIcon: true);

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(showIcon: false),
      errorBuilder: (context, error, stack) => _placeholder(showIcon: true),
    );
  }

  Widget _placeholder({required bool showIcon}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: showIcon
          ? Icon(Icons.image_outlined, color: Colors.grey.shade500, size: 32)
          : null,
    );
  }
}
