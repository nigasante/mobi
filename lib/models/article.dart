class Article {
  final int articleID;
  final String title;
  final String content;
  final int editorID;
  final String status;
  final String? publishDate;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String? imageUrl;
  final List<int>? categoryID;

  Article({
    required this.articleID,
    required this.title,
    required this.content,
    required this.editorID,
    required this.status,
    this.publishDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.imageUrl,
    this.categoryID,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      articleID: json['articleID'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      editorID: json['editorID'] ?? 0,
      status: json['status'] ?? '',
      publishDate: json['publishDate']?.toString(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      imageUrl: json['imageUrl'] as String?,
      categoryID: json['categoryID'] != null
          ? List<int>.from(json['categoryID'])
          : null,
    );
  }
}
