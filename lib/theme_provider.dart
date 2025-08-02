import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  ThemeData get theme {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: const Color.fromARGB(255, 22, 175, 152),
      surface: Colors.white,
      background: Colors.white,
      onSurface: Colors.black87,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 22, 175, 152),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[200], // Màu nền nhạt cho thanh tìm kiếm ở chế độ sáng
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.black54),
      prefixIconColor: Colors.black54,
      suffixIconColor: Colors.black54,
    ),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: const Color.fromARGB(255, 22, 175, 152),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      onSurface: Colors.white70,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 10, 10, 10),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 10, 12, 12),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C), // Màu nền đậm hơn nhưng dễ đọc ở chế độ tối
      border: InputBorder.none,
      hintStyle: TextStyle(color: Colors.white60),
      prefixIconColor: Colors.white60,
      suffixIconColor: Colors.white60,
    ),
  );
}