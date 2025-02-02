import 'package:bit_invest_sim/splashScreen.dart';
import 'package:flutter/material.dart';

// 앱의 주요 페이지 import
import 'coin/appBasePage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  // Firebase 초기화 코드 제거
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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
      initialRoute: '/splash', // 초기 라우트를 스플래시로 변경
      routes: {
        '/splash': (context) => SplashScreen(), // 스플래시 화면 추가
        '/base': (context) => AppBasePage(),
      },
    );
  }
}
