import 'package:flutter/material.dart';
import 'package:flutter_application_3/admin_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'category.dart'; // Import your model

// ...existing code...

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
  final List<int>? categoryID; // Make this a list of integers

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
    print(
      'Parsing article JSON: ${json['articleID']} with imageUrl: ${json['imageUrl']}',
    );

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

// ...existing code...

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
  // Initialize with default values to avoid late initialization errors
  int currentUserRoleId = 0;
  int currentUserId = 0;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.currentUserId;
    currentUserRoleId = widget.currentUserRoleId;
    fetchArticles();
    fetchCategories();
  }

  // Add this to your fetchArticles method

  Future<void> fetchArticles({int? categoryId}) async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5264/api/articles'),
      );
      if (response.statusCode == 200) {
        final String responseBody = response.body;
        print('API Response: $responseBody');

        final List<dynamic> data = json.decode(responseBody);

        // Debug each article JSON
        for (var item in data) {
          print('Article ${item['articleID']} imageUrl: ${item['imageUrl']}');
        }

        setState(() {
          articles = data.map((json) => Article.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch articles: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching articles: $e');
      setState(() => isLoading = false);
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
    // Filter articles based on role and status
    List<Article> visibleArticles = articles.where((article) {
      if (currentUserRoleId == 1 || currentUserRoleId == 2) {
        // Admin and Editor see all
        return true;
      } else {
        // Reader sees only Published
        return article.status == 'Published';
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle), backgroundColor: Colors.blue),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Danh mục',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
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
                      builder: (context) =>
                          AdminArticleManager(adminUserId: currentUserId),
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
          : visibleArticles.isEmpty
          ? Center(
              child: Text(
                "Không có bài viết trong danh mục này.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: visibleArticles.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleDetailPage(article: visibleArticles[index]),
                      ),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show image thumbnail if available
                      if (visibleArticles[index].imageUrl != null &&
                          visibleArticles[index].imageUrl!.isNotEmpty)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                visibleArticles[index].imageUrl!,
                              ),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {},
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                visibleArticles[index].title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                visibleArticles[index].status,
                                style: TextStyle(
                                  color:
                                      visibleArticles[index].status ==
                                          'Published'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final paragraphs = article.content
        .split(RegExp(r'(\r\n|\r|\n){2,}'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(article.title), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  article.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading detail image: $error');
                    return Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                          Text('Image not available', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: paragraphs
                    .map((paragraph) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            paragraph,
                            style: TextStyle(fontSize: 16, height: 1.6),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
