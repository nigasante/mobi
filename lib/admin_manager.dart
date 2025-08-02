import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'models/article.dart';
import 'category.dart';
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
          print('Article ${item["articleID"]} imageUrl: ${item["imageUrl"]}');
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
      Uri.parse('http://10.0.2.2:5264/api/articles/harddelete/$articleId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      setState(() {
        articles.removeWhere((a) => a.articleID == articleId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Article permanently deleted')));
      Navigator.pop(context, true); // Return true to trigger refresh on HomePage
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete article')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Return true to trigger refresh
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Article Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
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
                  if (updated == true) {
                    fetchArticles();
                  }
                });
              },
              tooltip: 'Create Article',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchArticles,
              tooltip: 'Refresh Articles',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  // Debug image URL for each article
                  print(
                    'Building article ${article.articleID} with imageUrl: ${article.imageUrl}',
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Image section - make it larger
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: _buildArticleImage(article),
                          ),
                          const SizedBox(width: 12),
                          // Content section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Status: ${article.status}'),
                                if (article.imageUrl != null &&
                                    article.imageUrl!.isNotEmpty)
                                  Text(
                                    'URL: ${article.imageUrl!.length > 30 ? "${article.imageUrl!.substring(0, 30)}..." : article.imageUrl}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Actions section
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
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
                                    if (updated == true) {
                                      fetchArticles();
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteArticle(article.articleID),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildArticleImage(Article article) {
    if (article.imageUrl == null || article.imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    String imageUrl = article.imageUrl!.trim();
    print('Loading image from Cloudinary: $imageUrl');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}',
        fit: BoxFit.cover,
        cacheWidth: null,
        cacheHeight: null,
        headers: {
          'Accept': 'image/*',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingContainer(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image ($imageUrl): $error');
          return _buildErrorContainer('Image not found');
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image_not_supported, size: 32, color: Colors.grey[400]),
    );
  }

  Widget _buildLoadingContainer(ImageChunkEvent loadingProgress) {
    return Container(
      width: 100,
      height: 100,
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
        ),
      ),
    );
  }

  Widget _buildErrorContainer(String errorMessage) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
