import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_page.dart'; // For Article model
import 'category.dart'; // For Category model
import 'edit_article_page.dart';

class AdminArticleManager extends StatefulWidget {
  final int adminUserId;

  const AdminArticleManager({super.key, required this.adminUserId});

  @override
  State<AdminArticleManager> createState() => _AdminArticleManagerState();
}

class _AdminArticleManagerState extends State<AdminArticleManager> {
  List<Article> articles = [];
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
    fetchCategories();
  }

  Future<void> fetchArticles() async {
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

          // Print decoded articles for debugging
          for (var article in articles) {
            print(
              'Parsed Article ${article.articleID}: imageUrl = ${article.imageUrl}',
            );
          }
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

  Future<void> deleteArticle(int articleId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:5264/api/articles/$articleId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        articles.removeWhere((a) => a.articleID == articleId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Article deleted')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete article')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Article Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditArticlePage(
                    article: null,
                    editorId: widget.adminUserId,
                    categories: categories,
                  ),
                ),
              ).then((updated) {
                if (updated == true) fetchArticles();
              });
            },
            tooltip: 'Create Article',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchArticles,
            tooltip: 'Refresh Articles',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                // Debug image URL for each article
                print(
                  'Building article ${article.articleID} with imageUrl: ${article.imageUrl}',
                );

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: _buildArticleImage(article),
                    title: Text(article.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${article.status}'),
                        if (article.imageUrl != null &&
                            article.imageUrl!.isNotEmpty)
                          Text(
                            'Image URL: ${article.imageUrl!.length > 30 ? article.imageUrl!.substring(0, 30) + "..." : article.imageUrl}',
                            style: TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditArticlePage(
                                  article: article,
                                  editorId: widget.adminUserId,
                                  categories: categories,
                                ),
                              ),
                            ).then((updated) {
                              if (updated == true) fetchArticles();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteArticle(article.articleID),
                        ),
                      ],
                    ),
                    isThreeLine:
                        article.imageUrl != null &&
                        article.imageUrl!.isNotEmpty,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildArticleImage(Article article) {
    if (article.imageUrl == null || article.imageUrl!.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.image_not_supported,
          size: 24,
          color: Colors.grey[400],
        ),
      );
    }

    print('Loading image in admin manager: ${article.imageUrl}');

    return Container(
      width: 60,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          article.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image in admin manager: $error');
            return Container(
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 20, color: Colors.red[900]),
                  Text(
                    'Error',
                    style: TextStyle(fontSize: 10, color: Colors.red[900]),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
