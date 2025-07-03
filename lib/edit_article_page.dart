import 'package:flutter/material.dart';
import 'home_page.dart'; // Make sure this points to where your Article model is

class EditArticlePage extends StatelessWidget {
  final Article? article;
  const EditArticlePage({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    final TextEditingController contentController =
        TextEditingController(text: article?.content ?? '');
    final TextEditingController titleController =
        TextEditingController(text: article?.title ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(article == null ? 'Tạo bài báo mới' : 'Sửa: ${article!.title}'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề bài báo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: contentController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration.collapsed(
                        hintText: 'Nhập nội dung bài báo...'),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement category selection
                    },
                    child: Text('Chọn thể loại'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement save or update logic
                      Navigator.pop(context);
                    },
                    child: Text(article == null ? 'Đăng tải' : 'Cập nhật'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}