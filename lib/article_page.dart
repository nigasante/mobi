// lib/screens/article_page.dart
import 'package:flutter/material.dart';

class ArticlePage extends StatelessWidget {
  final String content = 'Đây là nội dung bài báo. Kéo xuống để đọc tiếp...';

  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bài báo"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // mở thêm lựa chọn
              showModalBottomSheet(
                context: context,
                builder: (context) => ListView(
                  children: [
                    ListTile(title: Text('Thể loại 1')),
                    ListTile(title: Text('Thể loại 2')),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(content * 10),
      ),
    );
  }
}
