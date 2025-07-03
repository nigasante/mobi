// lib/main.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() => runApp(NewsApp());

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Đọc Báo',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Màn hình đầu tiên là login
      routes: {
        '/': (context) => LoginPage(),
       // '/home': (context) => HomePage(),
        //'/article': (context) => ArticlePage(),
        //'/manage': (context) => ManageArticlesPage(),
        //'/edit': (context) => EditArticlePage(),
      
      },
    );
  }
}
