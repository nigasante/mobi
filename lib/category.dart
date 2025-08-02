class Category {
  final int categoryID;
  final String name;

  Category({required this.categoryID, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryID: json['categoryID'],
      name: json['name'],
    );
  }
}
