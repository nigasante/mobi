import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_page.dart'; // For Article model
import 'category.dart';  // For Category model

class AdminArticleManager extends StatefulWidget {
  final int adminUserId; // Pass the admin's UserID

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
    final response = await http.get(Uri.parse('http://10.0.2.2:5264/api/articles'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        articles = data.map((json) => Article.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5264/api/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        categories = data.map((json) => Category.fromJson(json)).toList();
      });
    }
  }

  Future<void> deleteArticle(int articleId) async {
    final response = await http.delete(Uri.parse('http://10.0.2.2:5264/api/articles/$articleId'));
    if (response.statusCode == 200) {
      setState(() {
        articles.removeWhere((a) => a.articleID == articleId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Article deleted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete article')));
    }
  }

  Future<void> createOrUpdateArticle({Article? article}) async {
    final isNew = article == null;
    final titleController = TextEditingController(text: article?.title ?? '');
    final contentController = TextEditingController(text: article?.content ?? '');
    Category? selectedCategory = article != null
        ? categories.firstWhere((c) => c.categoryID == (article as dynamic).categoryID, orElse: () => categories.first)
        : null;
    String status = article?.status ?? 'Draft';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNew ? 'Create Article' : 'Update Article'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
              DropdownButtonFormField<Category>(
                value: selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (cat) => selectedCategory = cat,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: ['Draft', 'Published', 'Archived']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (s) => status = s ?? 'Draft',
                decoration: InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final body = {
                'title': titleController.text,
                'content': contentController.text,
                'editorID': widget.adminUserId,
                'status': status,
                'categoryID': selectedCategory?.categoryID,
              };
              http.Response response;
              if (isNew) {
                response = await http.post(
                  Uri.parse('http://10.0.2.2:5264/api/articles'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(body),
                );
              } else {
                response = await http.put(
                  Uri.parse('http://10.0.2.2:5264/api/articles/${article!.articleID}'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(body),
                );
              }
              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.pop(context);
                fetchArticles();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isNew ? 'Article created' : 'Article updated')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to ${isNew ? 'create' : 'update'} article')),
                );
              }
            },
            child: Text(isNew ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Article Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => createOrUpdateArticle(),
            tooltip: 'Create Article',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(article.title),
                    subtitle: Text('Status: ${article.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => createOrUpdateArticle(article: article),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteArticle(article.articleID),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}