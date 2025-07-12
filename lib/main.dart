import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Đọc Báo',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/': (context) => LoginPage()},
    );
  }
}