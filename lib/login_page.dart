import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      Navigator.pushReplacementNamed(context, '/home');
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
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(8),
          ),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
    );
  }
}
