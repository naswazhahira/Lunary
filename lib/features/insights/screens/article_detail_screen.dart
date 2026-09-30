import 'package:flutter/material.dart';
import '../models/article_model.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  void _showRelatedTopicsBottomSheet(BuildContext context) {
    final List<String> relatedTopics = [
      "Understanding the menstrual cycle",
      "Things to Know about Menstruation",
      "Unpunctual menstruation",
      "Relieving Period Cramps",
      "Managing Mood Swings",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Jelajahi Topik Lainnya",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2B4E),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...relatedTopics.map((topic) {
                final bool isCurrentCategory = topic == article.category;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCurrentCategory ? Icons.bookmark : Icons.article_outlined,
                    color: isCurrentCategory ? const Color(0xFF8E44AD) : Colors.grey[600],
                  ),
                  title: Text(
                    topic,
                    style: TextStyle(
                      fontWeight: isCurrentCategory ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentCategory ? const Color(0xFF8E44AD) : const Color(0xFF2D2B4E),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    if (!isCurrentCategory) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Beralih ke topik: $topic')),
                      );
                    }
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2B4E),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showRelatedTopicsBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6D8E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E44AD),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: Color(0xFF8E44AD),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                article.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              article.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}