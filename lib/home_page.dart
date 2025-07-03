import 'package:flutter/material.dart';
import 'package:flutter_application_3/admin_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'category.dart'; // Import your model

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
      imageUrl: json['imageUrl'],
    );
  }
}

class HomePage extends StatefulWidget {
  final int currentUserId;
  final int currentUserRoleId;

  const HomePage({
    super.key,
    required this.currentUserId,
    required this.currentUserRoleId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Article> articles = [];
  List<Category> categories = [];
  bool isLoading = true;
  int? selectedCategoryId;
  String? selectedCategory;
  late int currentUserRoleId;
  late int currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.currentUserId;
    currentUserRoleId = widget.currentUserRoleId;
    fetchArticles();
    fetchCategories();
  }

  Future<void> fetchArticles({int? categoryId}) async {
    String url = 'http://10.0.2.2:5264/api/articles';
    if (categoryId != null) {
      url += '?categoryId=$categoryId';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        articles = data.map((json) => Article.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5264/api/categories'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        categories = data.map((json) => Category.fromJson(json)).toList();
      });
    }
  }

  void _onCategorySelected(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      isLoading = true;
    });
    fetchArticles(categoryId: categoryId);
    Navigator.pop(context);
  }

  void _logout() {
    // TODO: Add your logout logic here (e.g., clear session, tokens, etc.)
    // Then navigate to login page
    Navigator.of(context).pushReplacementNamed('/');
  }

  bool _isAdmin() {
    return currentUserRoleId == 1;
  }

  String get appBarTitle {
    if (selectedCategoryId == null) return "Tin tức";
    final selected = categories.firstWhere(
      (c) => c.categoryID == selectedCategoryId,
      orElse: () => Category(categoryID: 0, name: "Tin tức"),
    );
    return selected.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle), backgroundColor: Colors.blue),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Danh mục', style: TextStyle(fontSize: 20, color: Colors.white)),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: Text('Tất cả'),
              selected: selectedCategoryId == null,
              onTap: () => _onCategorySelected(null),
            ),
            ...categories.map(
              (cat) => ListTile(
                title: Text(cat.name),
                selected: selectedCategoryId == cat.categoryID,
                onTap: () => _onCategorySelected(cat.categoryID),
              ),
            ),
            Divider(),
            if (_isAdmin())
              ListTile(
                leading: Icon(Icons.admin_panel_settings, color: Colors.orange),
                title: Text('Quản lý bài viết'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminArticleManager(
                        adminUserId: currentUserId,
                      ),
                    ),
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Đăng xuất'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? Center(
                  child: Text(
                    "Không có bài viết trong danh mục này.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(articles[index].title),
                    subtitle: Text(articles[index].status),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ArticleDetailPage(article: articles[index]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paragraphs = article.content
        .split(RegExp(r'(\r\n|\r|\n){2,}'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(article.title), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: paragraphs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              paragraphs[index],
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}