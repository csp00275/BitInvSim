import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../data/user.dart';

class SignPage extends StatefulWidget {
  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  late DatabaseReference reference;
  final String _databaseURL =
      'https://bitinvestsim-default-rtdb.firebaseio.com/';

  late TextEditingController _idTextController;
  late TextEditingController _pwTextController;
  late TextEditingController _pwCheckTextController;

  @override
  void initState() {
    super.initState();
    _idTextController = TextEditingController();
    _pwTextController = TextEditingController();
    _pwCheckTextController = TextEditingController();

    final database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = database.reference().child('user');
  }

  bool isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$');
    return regex.hasMatch(password);
  }

  bool isValidId(String id) {
    final regex = RegExp(r'^[a-zA-Z0-9]{4,}$');
    return regex.hasMatch(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _idTextController,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: '4자 이상 입력해주세요',
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _pwTextController,
                obscureText: true,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: '6자 이상 입력해주세요',
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _pwCheckTextController,
                obscureText: true,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String id = _idTextController.text.trim();
                String password = _pwTextController.text.trim();
                String passwordCheck = _pwCheckTextController.text.trim();

                if (!isValidId(id)) {
                  makeDialog('아이디는 4자 이상이어야 하며, 알파벳과 숫자만 포함해야 합니다.');
                  return;
                }

                if (!isValidPassword(password)) {
                  makeDialog('비밀번호는 최소 6자 이상이며, 대소문자와 숫자를 포함해야 합니다.');
                  return;
                }

                if (password != passwordCheck) {
                  makeDialog('비밀번호가 일치하지 않습니다.');
                  return;
                }

                var digest = sha256.convert(utf8.encode(password));
                reference
                    .child(id)
                    .set(
                      User(
                        id: id,
                        password: digest.toString(),
                        createTime: DateTime.now().toIso8601String(),
                      ).toJson(),
                    )
                    .then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }

  void makeDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
