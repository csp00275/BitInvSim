import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('Building login');
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 아이디 입력란
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              // 비밀번호 입력란
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              // 로그인 버튼
              ElevatedButton(
                onPressed: () {
                  String id = _idController.text.trim();
                  String password = _passwordController.text.trim();

                  if (id.isEmpty || password.isEmpty) {
                    _showDialog(context, '빈칸이 있습니다!');
                  } else {
                    // 여기에 로그인 로직 추가
                    print('아이디: $id, 비밀번호: $password');
                    _showDialog(context, '로그인 성공!');
                    Navigator.pushNamed(context, '/base'); // 회원가입 화면으로 이동
                  }
                },
                child: Text(
                  '로그인',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              // 회원가입 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/sign'); // 회원가입 화면으로 이동
                },
                child: Text(
                  '회원가입',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/base'); // 회원가입 화면으로 이동
                },
                child: Text(
                  '개발자로그인',
                  style: TextStyle(color: Colors.red),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
