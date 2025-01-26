import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  final String id;
  final String pw;
  final String createTime;

  User({required this.id, required String password, required this.createTime})
      : pw = _hashPassword(password);

  User.fromSnapshot(DataSnapshot snapshot)
      : id = (snapshot.value as Map<String, dynamic>?)?['id'] ?? '',
        pw = (snapshot.value as Map<String, dynamic>?)?['pw'] ?? '',
        createTime = (snapshot.value as Map<String, dynamic>?)?['createTime'] ?? '';

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Map<String, String> toJson() {
    return {
      'id': id,
      'pw': pw,
      'createTime': createTime,
    };
  }
}