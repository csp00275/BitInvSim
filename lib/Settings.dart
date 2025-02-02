import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// -----------------------------
// 애니메이션용 페이지 라우트
// -----------------------------
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 오른쪽에서 왼쪽으로 슬라이딩하는 애니메이션
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

// -----------------------------
// SettingsPage: 설정 메인 페이지
// -----------------------------
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // 앱 정보
          ListTile(
            title: const Text(
              '앱 정보',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const AppInfoPage()),
              );
            },
          ),
          // 적립식 투자란?
          ListTile(
            title: const Text(
              '적립식 투자란?',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const InvInfoPage()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'BITCOIN vs GOD',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: BitcoinIsGodPage()),
              );
            },
          ),
          ListTile(
            title: const Text(
              '개발자의 주절주절',
              style: TextStyle(fontSize: 20.0),
            ),
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(page: const DeveloperNotePage()),
              );
            },
          ),

          // 필요한 다른 설정 항목들...
        ],
      ),
    );
  }
}

class InvInfoPage extends StatefulWidget {
  const InvInfoPage({Key? key}) : super(key: key);

  @override
  _InvInfoPageState createState() => _InvInfoPageState();
}

class _InvInfoPageState extends State<InvInfoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;

  // 페이지에 보여줄 섹션들을 순서대로 정의합니다.
  // InvestmentAdvantages와 InvestmentConsiderations는
  // 내부 애니메이션 없이 단순히 내용을 표시하는 상태라고 가정합니다.
  final List<Widget> _sections = [
    // 1. 소개 텍스트
    Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: const Text(
        '적립식 투자는 정기적으로 일정 금액을 정해진 투자 상품에 꾸준히 투자하는 방식입니다. '
        '보통 매월 일정 금액을 적립하여 주식, 펀드, 채권 등 다양한 금융 상품에 투자하게 됩니다. '
        '이러한 투자 방식은 다음과 같은 장점을 가지고 있습니다:',
        style: TextStyle(fontSize: 16.0, height: 1.5),
      ),
    ),
    // 2. InvestmentAdvantages
    const InvestmentAdvantages(),
    // 3. InvestmentConsiderations
    const InvestmentConsiderations(),
    // 4. 마무리 텍스트
    Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: const Text(
        '적립식 투자는 특히 투자 초보자에게 적합하며, 꾸준히 투자함으로써 장기적인 재무 목표를 '
        '달성하는 데 도움을 줄 수 있습니다. 그러나 모든 투자는 리스크가 따르므로, '
        '자신의 재정 상황과 투자 목표를 충분히 고려한 후에 시작하는 것이 좋습니다.',
        style: TextStyle(fontSize: 16.0, height: 1.5),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 섹션 개수에 따라 전체 애니메이션 총 시간을 설정합니다.
    // 여기서는 각 섹션마다 0.5초씩 -> 총 시간 = 섹션수 * 0.5초
    final totalDuration = Duration(milliseconds: _sections.length * 500);

    _controller = AnimationController(vsync: this, duration: totalDuration);

    // 각 섹션마다 staggered interval을 적용합니다.
    _fadeAnimations = List.generate(_sections.length, (index) {
      double start = index / _sections.length;
      double end = (index + 1) / _sections.length;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeIn),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('적립식 투자')),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_sections.length, (index) {
              return FadeTransition(
                opacity: _fadeAnimations[index],
                child: _sections[index],
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// InvestmentAdvantages 위젯 (내부 애니메이션 제거, 단순 내용 표시)
class InvestmentAdvantages extends StatelessWidget {
  const InvestmentAdvantages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final advantages = [
      {
        'title': '1. 분산 투자 효과',
        'description': '일정 금액을 정기적으로 투자함으로써 시장의 변동성에 영향을 덜 받게 됩니다. '
            '가격이 높을 때는 적은 수량을, 가격이 낮을 때는 많은 수량을 구매하게 되어 평균 매입 단가를 낮출 수 있습니다.'
      },
      {
        'title': '2. 투자 습관 형성',
        'description': '매달 일정 금액을 자동으로 투자함으로써 꾸준한 투자 습관을 기를 수 있습니다. '
            '이는 장기적인 자산 형성에 큰 도움이 됩니다.'
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
      children: [
        const Text(
          '적립식 투자 장점',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        ...advantages.map((adv) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                adv['title']!,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 8.0),
                  child: Text(
                    adv['description']!,
                    style: const TextStyle(fontSize: 14.0, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

/// InvestmentConsiderations 위젯 (내부 애니메이션 제거, 단순 내용 표시)
class InvestmentConsiderations extends StatelessWidget {
  const InvestmentConsiderations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final considerations = [
      {
        'title': '투자 기간',
        'description':
            '장기적인 시각으로 투자하는 것이 유리합니다. 단기적인 시장 변동에 일희일비하지 않는 마음가짐이 필요합니다.',
      },
      {
        'title': '투자 상품 선택',
        'description':
            '자신의 투자 성향과 목표에 맞는 상품을 선택하는 것이 중요합니다. 다양한 상품을 비교하고 리스크를 충분히 고려해야 합니다.',
      },
      {
        'title': '자동화 설정',
        'description': '자동이체 등을 설정하여 투자 계획을 지속적으로 유지하는 것이 중요합니다.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '적립식 투자 시 고려할 점',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        ...considerations.map((c) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                c['title']!,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 8.0),
                  child: Text(
                    c['description']!,
                    style: const TextStyle(fontSize: 14.0, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

// -----------------------------
// 앱 정보 페이지
// -----------------------------
class AppInfoPage extends StatelessWidget {
  const AppInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 페이지 공통 Padding 설정
    const double horizontalPadding = 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('앱 정보')),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
                style: TextStyle(fontSize: 16.0, height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                "데이터 (Data):\n"
                "이 앱의 데이터는 업비트 API를 사용하였습니다. 업비트 원화마켓 기준 데이터입니다. "
                "투자 시작 가능 날짜는 업비트 원화마켓에 상장일을 기준으로 합니다.",
                style: TextStyle(fontSize: 16.0, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 비트코인을 '신앙'에 비유한 패러디 ExpansionTile 예시

/// 비트코인을 '신'에 비유한 패러디 예시 페이지

class BitcoinIsGodPage extends StatefulWidget {
  const BitcoinIsGodPage({Key? key}) : super(key: key);

  @override
  _BitcoinIsGodPageState createState() => _BitcoinIsGodPageState();
}

class _BitcoinIsGodPageState extends State<BitcoinIsGodPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;

  // 비트코인을 '신'에 비유한 패러디 항목들
  final List<Map<String, String>> bitcoinFaithItems = [
    {
      'title': '1. “비트 신앙”의 탄생',
      'description':
          '기원후 2009년에 사토시 나카모토라는 ‘예언자’가 등장하여, 성스러운 백서(Whitepaper)를 전파함으로써 시작되었습니다. 사람들은 백서를 경전처럼 모시며, 블록체인 기술을 교리처럼 학습하기 시작했습니다.',
      'img': 'assets/imgSetting/01BitBorn.png'
    },
    {
      'title': '2. 비트코인과 십일조',
      'description':
          '종교에서 신앙심을 표현하기 위해 십일조를 내듯, 비트코인에서는 ‘매수’를 합니다. 십일조가 마음의 평화를 준다면, 비트코인의 매수는 물질적 이득(혹은 손실…)을 불러올 수 있습니다. 둘 다 맹목적이면 위험할 수도 있지요.',
      'img': 'assets/imgSetting/02BitPay.png',
    },
    {
      'title': '3. 블록체인 성서 vs. 성경',
      'description':
          '기독교인이 성경의 장과 절을 외우듯, 비트 신도는 백서와 블록체인 구조를 암송하듯 익힙니다. 지갑 주소, 채굴 난이도, 반감기 메커니즘 등이 일종의 “블록체인 성서”로 여겨집니다. 믿고 따르는 자에게 복이 있나니...',
      'img': 'assets/imgSetting/03BitBible.png',
    },
    {
      'title': '4. 예언자들의 등장',
      'description':
          '종교에 예언자나 성인이 있듯, 비트코인 커뮤니티에도 “전설의 트레이더”나 “차트 신봉자”들이 있습니다. 그들은 차트를 보며 폭등·폭락 시점을 예언하고, 신도들은 이 예언에 일희일비하게 됩니다.',
      'img': 'assets/imgSetting/04BitForetell.png',
    },
    {
      'title': '5. 집회와 포교 활동',
      'description':
          '종교 집회처럼, 암호화폐 컨퍼런스나 밋업이 열리고, 코인 전도사들은 “이것은 혁명이다!”를 외치며 사람들을 끌어들입니다. 새로운 코인이 생길 때마다 진짜 vs. 가짜, 정통(비트코인) vs. 이단(알트코인) 논쟁이 벌어지기도 합니다.',
      'img': 'assets/imgSetting/05BitMeeting.png',
    },
    {
      'title': '6. 구원의 여정: 홀딩(HODL)',
      'description':
          '종교에서는 인내와 믿음으로 구원에 이른다고 하지요. 비트코인에서도 “HODL(홀딩)”이라는 미덕이 있습니다. 흔들림 없이 믿고 버틴 자가 높은 수익을 얻었다는 전설이 있으나, 반대로 빛을 못 보기도 합니다. 결국 신앙심(?)이 중요?',
      'img': 'assets/imgSetting/06HODL.png',
    },
    {
      'title': '7. 결론: 신앙과 투자 사이',
      'description':
          '종교적 신앙은 정신적 가치를, 비트코인 신앙은 물질적 가능성을 추구합니다. 하지만 둘 다 맹신은 위험합니다. 제대로 이해하고, 자기 기준에 따라 믿음을 (투자를) 가져야 한다는 점에서, 의외로 닮아있습니다.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // 전체 애니메이션 시간: 항목 개수 * 0.5초 (7개면 3.5초)
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3500));

    _fadeAnimations = List.generate(bitcoinFaithItems.length, (index) {
      double start = index / bitcoinFaithItems.length;
      double end = (index + 1) / bitcoinFaithItems.length;
      return CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeIn));
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비트코인은 신인가?')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(bitcoinFaithItems.length, (index) {
            final item = bitcoinFaithItems[index];
            return FadeTransition(
              opacity: _fadeAnimations[index],
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    item['title']!,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                  children: [
                    if (item.containsKey('img') && item['img'] != null)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 8.0),
                        child: Image.asset(item['img']!),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(
                        item['description']!,
                        style: const TextStyle(fontSize: 14.0, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class DeveloperNotePage extends StatefulWidget {
  const DeveloperNotePage({Key? key}) : super(key: key);

  @override
  _DeveloperNotePageState createState() => _DeveloperNotePageState();
}

class _DeveloperNotePageState extends State<DeveloperNotePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;

  // 문단 내용 리스트 (첫 번째는 제목, 나머지는 본문)
  final List<String> _paragraphs = [
    "투자의 심리: 믿음과 규칙 그리고 실행의 중요성",
    "투자 세계에서 끊임없이 마주치는 질문인, \"투자해야 하나? 지금이 매도의 적기인가?\"에 대한 해답은 간단하지 않습니다. 실제로, 이러한 결정의 근간은 개인의 깊은 믿음과 엄격한 규칙에 기반을 두고 있어야 합니다. 투자는 단순한 자산의 매매를 넘어선, 자기 자신과의 지속적인 대화와 반성을 요구하는 과정입니다.",
    "일상에서 우리가 겪는 도전들, 예컨대 꾸준한 학습의 필요성이나 정기적인 운동의 중요성은 투자에서도 유사하게 적용됩니다. 이러한 일상적 실천이 개인의 성장과 건강에 긍정적인 영향을 미치듯, 투자에서의 지속성과 일관성 또한 장기적인 성공으로 이어집니다.",
    "적립식 투자는 이러한 도전에 대한 하나의 해결책을 제시합니다. 정해진 날짜에 정해진 금액으로 규칙적인 투자를 함으로써, 투자자는 복잡한 시장 분석이나 예측의 필요성을 최소화하며, 시장의 변동성을 자신의 이점으로 활용할 수 있습니다.",
    "그러나 투자의 위험성은 투자자 본인의 선택에 달려 있습니다. 전체 자산을 고위험 자산에 투자하는 것은 공격적인 전략이 될 수 있지만, 동시에 손실의 가능성도 크게 늘어납니다. 반대로, 대부분의 자산을 안정적인 적금에 할당하고, 나머지를 고위험 자산에 소량 투자하는 경우, 손실 가능성을 제한할 수 있습니다.",
    "여기에서 내가 더할 생각은, 투자의 성공은 개인의 믿음과 규칙을 넘어, 이 두 가지를 어떻게 조화롭게 실행하는가에 달려 있다는 것입니다. 자신만의 투자 철학을 확립하고, 그에 맞는 일관된 행동을 취하는 것이 중요합니다. 이런 접근 방식을 통해, 투자자는 변동성이 큰 시장 속에서도 자신의 경로를 유지하며, 장기적인 관점에서 의미 있는 성과를 달성할 수 있을 것입니다.",
  ];

  @override
  void initState() {
    super.initState();
    // 전체 애니메이션 총 시간: 문단 개수 * 0.5초 (여기서는 6개 × 0.5 = 3초)
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    // 각 문단마다 0.5초 간격의 페이드 인 효과를 주기 위한 애니메이션 생성
    _fadeAnimations = List.generate(_paragraphs.length, (index) {
      // 문단 i의 애니메이션 시작 시간 = i * 0.5초, 종료 시간 = (i+1)*0.5초
      // 전체 duration이 3초이므로, interval은 [i/6, (i+1)/6]
      double start = index / _paragraphs.length;
      double end = (index + 1) / _paragraphs.length;
      return CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeIn));
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("개발자의 한마디")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_paragraphs.length, (index) {
              return FadeTransition(
                opacity: _fadeAnimations[index],
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _paragraphs[index],
                    style: TextStyle(
                      fontSize: index == 0 ? 20 : 16,
                      fontWeight:
                          index == 0 ? FontWeight.bold : FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
