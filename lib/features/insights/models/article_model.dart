class Article {
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String category;

  Article({
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.category,
  });
}

class InsightCategory {
  final String title;
  final String bannerImage;
  final List<Article> articles;

  InsightCategory({
    required this.title,
    required this.bannerImage,
    required this.articles,
  });
}

class InsightSection {
  final String title;
  final List<InsightCategory> categories;

  InsightSection({
    required this.title,
    required this.categories,
  });
}