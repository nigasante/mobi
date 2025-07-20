import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final url = Uri.parse('http://10.0.2.2:5264/api/users/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final int userId = data['userID'];
      final int roleId = data['roleID'];

      // ✅ Navigate and pass both values
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            currentUserId: userId,
            currentUserRoleId: roleId,
          ),
        ),
      );
    } else {
      setState(() {
        error = 'Đăng nhập thất bại. Vui lòng kiểm tra lại!';
      });
    }
  }
  void _showSignUpDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Đăng ký"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInputField("Tên", nameController),
            SizedBox(height: 10),
            _buildInputField("Email", emailController),
            SizedBox(height: 10),
            _buildInputField("Mật khẩu", passwordController, obscure: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final password = passwordController.text;

              final url = Uri.parse(
                'http://10.0.2.2:5264/api/users/signup?name=$name&email=$email&password=$password',
              );

              final response = await http.post(url);

              Navigator.pop(context);

              if (response.statusCode == 200) {
                _showDialog('Tạo tài khoản thành công! Hãy đăng nhập.', true);
              } else {
                _showDialog('Lỗi đăng ký: ${response.body}', false);
              }
            },
            child: Text("Đăng ký"),
          ),
        ],
      ),
    );
  }

  void _showDialog(String message, bool success) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? 'Thành công' : 'Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ảnh nền
          Positioned.fill(
            child: Image.asset(
              'assets/images/vintage_newspaper.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Lớp mờ để tăng khả năng đọc chữ
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Form đăng nhập
          Center(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border.all(),
                borderRadius: BorderRadius.circular(8),
              ),
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Đăng Nhập',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    onPressed: login,
                    child: Text("Đăng nhập"),
                  ),
                  TextButton(
                    onPressed: _showSignUpDialog,
                    child: Text("Chưa có tài khoản? Đăng ký"),
                  ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(error, style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
