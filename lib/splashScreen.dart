import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:bit_invest_sim/coin/appBasePage.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // 단일 offset 세트 사용 (차트 애니메이션용)
  final List<Offset> points = [
    const Offset(0, -50),
    Offset(30, -22),
    Offset(60, -13),
    Offset(90, 2),
    Offset(120, 18),
    Offset(150, -12),
    Offset(180, 27),
    Offset(210, -3),
    Offset(240, 33),
    Offset(270, 12),
    Offset(300, 80),
  ];

  double pathProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // 차트 애니메이션 컨트롤러 설정 (전체 애니메이션 지속 시간 2000ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 애니메이션 Tween 설정
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          pathProgress = _animation.value;
        });
      });

    _controller.forward();

    // 2500ms 후 메인 화면으로 전환 (페이드 효과 적용)
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) {
              // BaseScreen()는 실제 전환할 화면으로 교체하세요.
              return AppBasePage();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          // 내용이 많을 경우 스크롤 가능하도록 함
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D 비트코인 모델 (회전 없이 고정된 상태)
              SizedBox(
                width: 200,
                height: 200,
                child: ModelViewer(
                  src: 'assets/models/bitcoin.glb',
                  // glb 파일 경로
                  alt: "A 3D model of Bitcoin",
                  autoRotate: false,
                  // 자동 회전 비활성화
                  cameraControls: false,
                  // 사용자 카메라 컨트롤 비활성화
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                '적립식 투자 시뮬레이션',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GmarketSans',
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "기회가 될 변동성, 적립식으로 잡는다\n"
                "장기적으로 보며 꾸준히 투자를!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'GmarketSans',
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32.0),
              // 차트 애니메이션 (로딩 인디케이터 자리)
              SizedBox(
                width: 320,
                height: 200,
                child: CustomPaint(
                  painter: SmoothChartPainter(points, pathProgress),
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}

// 부드러운 차트 그리기 클래스 (변경 없음)
class SmoothChartPainter extends CustomPainter {
  final List<Offset> points;
  final double progress;

  SmoothChartPainter(this.points, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final Paint linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint dotPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(points[0].dx, size.height / 2 - points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, size.height / 2 - points[i].dy);
    }

    // PathMetrics를 사용하여 현재 진행도에 맞는 Path 부분만 그리기
    PathMetrics pathMetrics = path.computeMetrics();
    Path currentPath = Path();

    pathMetrics.forEach((PathMetric metric) {
      currentPath.addPath(
        metric.extractPath(0.0, metric.length * progress),
        Offset.zero,
      );
    });

    canvas.drawPath(currentPath, linePaint);

    // 각 점 그리기
    for (int i = 0; i < points.length; i++) {
      double pointProgress = _getPointProgress(i, points.length);
      if (progress >= pointProgress) {
        canvas.drawCircle(
          Offset(points[i].dx, size.height / 2 - points[i].dy),
          5,
          dotPaint,
        );
      }
    }
  }

  double _getPointProgress(int index, int total) {
    if (total <= 1) return 1.0;
    return index / (total - 1);
  }

  @override
  bool shouldRepaint(covariant SmoothChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.points != points;
  }
}
