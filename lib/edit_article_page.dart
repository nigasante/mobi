import 'package:flutter/material.dart';
import 'home_page.dart'; // for Article model
import 'category.dart';  // for Category model
import 'dart:convert';
import 'package:http/http.dart' as http;


class EditArticlePage extends StatefulWidget {
  final Article? article;
  final int editorId;
  final List<Category> categories;

  const EditArticlePage({
    super.key,
    this.article,
    required this.editorId,
    required this.categories,
  });

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _status = 'Draft';
  List<int> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _status = widget.article!.status;
      // You can pre-fill _selectedCategoryIds if your Article model supports it
    }
  }

  Future<void> _submitArticle() async {
    final url = widget.article == null
        ? 'http://10.0.2.2:5264/api/articles'
        : 'http://10.0.2.2:5264/api/articles/${widget.article!.articleID}';

    final method = widget.article == null ? 'POST' : 'PUT';

    final response = await (method == 'POST'
        ? http.post(Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'title': _titleController.text,
              'content': _contentController.text,
              'editorID': widget.editorId,
              'status': _status,
              'publishDate': DateTime.now().toIso8601String(),
              'categoryIDs': _selectedCategoryIds,
            }))
        : http.put(Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'title': _titleController.text,
              'content': _contentController.text,
              'editorID': widget.editorId,
              'status': _status,
              'publishDate': DateTime.now().toIso8601String(),
              'categoryIDs': _selectedCategoryIds,
            })));

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true); // signal refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save article'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.article == null ? 'Tạo bài báo mới' : 'Chỉnh sửa bài báo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Nội dung'),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Draft', 'Published', 'Archived']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _status = val!;
                });
              },
              decoration: const InputDecoration(labelText: 'Trạng thái'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: widget.categories.map((cat) {
                  final selected = _selectedCategoryIds.contains(cat.categoryID);
                  return CheckboxListTile(
                    title: Text(cat.name),
                    value: selected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedCategoryIds.add(cat.categoryID);
                        } else {
                          _selectedCategoryIds.remove(cat.categoryID);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _submitArticle,
              child: Text(widget.article == null ? 'Đăng bài' : 'Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}


