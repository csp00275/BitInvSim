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
          ListTile(
            title: Text(
              '적립식 투자란?',
              style: TextStyle(fontSize: 30.0),
            ),
            onTap: () {
              // 앱 정보 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InvInfoPage()),
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
class InvInfoPage extends StatelessWidget {
  const InvInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('적립식 투자')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '적립식 투자는 정기적으로 일정 금액을 정해진 투자 상품에 꾸준히 투자하는 방식입니다. 보통 매월 일정 금액을 적립하여 주식, 펀드, 채권 등 다양한 금융 상품에 투자하게 됩니다. 이러한 투자 방식은 다음과 같은 장점을 가지고 있습니다:',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),

              // 장점 리스트
              InvestmentAdvantages(),
              SizedBox(height: 16.0),

              // 고려할 점
              Text(
                '적립식 투자 시 고려할 점:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              InvestmentConsiderations(),
              SizedBox(height: 16.0),

              // 마무리
              Text(
                '적립식 투자는 특히 투자 초보자에게 적합하며, 꾸준히 투자함으로써 장기적인 재무 목표를 달성하는 데 도움을 줄 수 있습니다. 그러나 모든 투자는 리스크가 따르므로, 자신의 재정 상황과 투자 목표를 충분히 고려한 후에 시작하는 것이 좋습니다.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvestmentAdvantages extends StatelessWidget {
  // 장점 리스트 위젯
  @override
  Widget build(BuildContext context) {
    // 장점 목록
    final advantages = [
      {
        'title': '1. 분산 투자 효과',
        'description':
            '일정 금액을 정기적으로 투자함으로써 시장의 변동성에 영향을 덜 받게 됩니다. 가격이 높을 때는 적은 수량을, 가격이 낮을 때는 많은 수량을 구매하게 되어 평균 매입 단가를 낮출 수 있습니다.'
      },
      {
        'title': '2. 투자 습관 형성',
        'description':
            '매달 일정 금액을 자동으로 투자함으로써 꾸준한 투자 습관을 기를 수 있습니다. 이는 장기적인 자산 형성에 도움이 됩니다.'
      },
      {
        'title': '3. 심리적 부담 감소',
        'description': '일시불 투자에 비해 초기 자금 부담이 적어, 투자에 대한 심리적 부담을 줄일 수 있습니다.'
      },
      {
        'title': '4. 복리 효과 활용',
        'description': '장기간에 걸쳐 투자하면 복리의 효과를 누릴 수 있어 자산이 더욱 성장할 가능성이 높아집니다.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: advantages.map((advantage) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16.0, color: Colors.black),
              children: [
                TextSpan(
                  text: '${advantage['title']}:\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: advantage['description'],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class InvestmentConsiderations extends StatelessWidget {
  // 고려할 점 리스트 위젯
  @override
  Widget build(BuildContext context) {
    // 고려할 점 목록
    final considerations = [
      {
        'title': '• 투자 기간',
        'description':
            '장기적인 시각으로 투자하는 것이 유리합니다. 단기적인 시장 변동에 일희일비하지 않는 마음가짐이 필요합니다.'
      },
      {
        'title': '• 투자 상품 선택',
        'description':
            '자신의 투자 성향과 목표에 맞는 상품을 선택하는 것이 중요합니다. 다양한 상품을 비교하고 리스크를 고려해야 합니다.'
      },
      {
        'title': '• 자동화 설정',
        'description': '자동이체 등을 설정하여 투자 계획을 지속적으로 유지하는 것이 중요합니다.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: considerations.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16.0, color: Colors.black),
              children: [
                TextSpan(
                  text: '${item['title']}: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: item['description'],
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
