import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

class ManageArticlesPage extends StatefulWidget {
  const ManageArticlesPage({super.key});

  @override
  State<ManageArticlesPage> createState() => _ManageArticlesPageState();
}

class _ManageArticlesPageState extends State<ManageArticlesPage> {
  List<Article> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5264/api/articles'));
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

  Future<void> deleteArticle(int id) async {
    final response = await http.delete(Uri.parse('http://10.0.2.2:5264/api/articles/$id'));
    if (response.statusCode == 200) {
      fetchArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý bài báo'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/edit');
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ListTile(
                  title: Text(article.title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteArticle(article.articleID);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
