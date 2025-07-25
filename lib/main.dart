import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your homepage
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
      initialRoute: '/', // This stays the same
      routes: {
        '/': (context) => HomePage( currentUserId: 3, // Provide a valid user ID
    currentUserRoleId: 3,), // Show HomePage first
        '/login': (context) => LoginPage(), // Login page route
      },
    );
  }
}