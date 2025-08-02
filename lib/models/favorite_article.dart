class FavoriteArticle {
  final int userID;
  final int articleID;
  final DateTime savedAt;

  FavoriteArticle({
    required this.userID,
    required this.articleID,
    required this.savedAt,
  });

  factory FavoriteArticle.fromJson(Map<String, dynamic> json) {
    return FavoriteArticle(
      userID: json['userID'],
      articleID: json['articleID'],
      savedAt: DateTime.parse(json['savedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'articleID': articleID,
    };
  }
}
