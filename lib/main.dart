import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NewsApp(),
    ),
  );
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => MaterialApp(
        title: 'App Đọc Báo',
        debugShowCheckedModeBanner: false,
        theme: themeProvider.theme,
        home: const AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  int currentUserId = 0;
  int currentUserRoleId = 0;

  void _handleLogin(int userId, int roleId) {
    setState(() {
      currentUserId = userId;
      currentUserRoleId = roleId;
    });
    Navigator.pop(context); // Close login page
  }

  void _handleLogout() {
    setState(() {
      currentUserId = 0;
      currentUserRoleId = 0;
    });
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(onLoginSuccess: _handleLogin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      currentUserId: currentUserId,
      currentUserRoleId: currentUserRoleId,
      onLoginTap: _navigateToLogin,
      onLogout: _handleLogout,
    );
  }
}
  