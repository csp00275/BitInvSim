// 예: SettingsPage.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('설정')),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              '앱 정보',
              style: TextStyle(fontSize: 30.0),
            ),
            onTap: () {
              // 앱 정보 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppInfoPage()),
              );
            },
          ),
          // 다른 설정 항목들...
        ],
      ),
    );
  }
}

// 예: AppInfoPage.dart (면책조항/개발자 정보 등 표시)
class AppInfoPage extends StatelessWidget {
  const AppInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('앱 정보')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "앱 이름: 적립식 투자 시뮬레이터",
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                "버전: 1.0.0",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16),
              Text(
                "개발자: 박재형",
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                "연락처: csp00275@gmail.com",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16),
              Text(
                "면책조항 (Disclaimer):\n"
                "이 앱은 가상 시뮬레이션을 통해 수익률 등을 테스트하기 위한 용도로 개발되었습니다. "
                "실제 투자에 대한 판단은 사용자 본인이 하셔야 하며, 어떠한 투자 결과에 대해서도 "
                "본 앱은 책임지지 않습니다.\n",
                style: TextStyle(fontSize: 16.0),
              ),

              SizedBox(height: 16),
              Text(
                "데이터 (Data):\n"
                "이 앱의 데이터는 업비트 API를 사용하였습니다. 업비트 원화마켓 기준 데이터입니다. 투자 시작 가능 날짜는 업비트 원화마켓에 상장일을 기준으로 합니다.",
                style: TextStyle(fontSize: 16.0),
              ),
              // 필요하다면 더 자세한 내용...
            ],
          ),
        ),
      ),
    );
  }
}
