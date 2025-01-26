import 'package:bit_invest_sim/signup/loginPage.dart';
import 'package:bit_invest_sim/signup/signPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'coin/appBasePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  try {
    await Firebase.initializeApp(); // Firebase 초기화
    print("Firebase 초기화 성공!");
  } catch (e) {
    print("Firebase 초기화 실패: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bit Simulation',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/sign': (context) => SignPage(),
        '/base': (context) => AppBasePage(),
      },
    );
  }
}
