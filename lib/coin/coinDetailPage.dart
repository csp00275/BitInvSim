// lib/coin/coin_detail_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart'; // CSV 파싱
import 'package:intl/intl.dart';

import 'coindetail/InvResultsPage.dart';
import 'coindetail/InvSettingsPage.dart';
import 'coindetail/datePickerRow.dart';

class CoinDetailPage extends StatefulWidget {
  final String name;
  final String image;
  final String description;

  // ➊ CSV 파일 경로만 넘어옴
  final String csvFilePath;
  final Color color;
  final DateTime invStartDate;

  const CoinDetailPage({
    Key? key,
    required this.name,
    required this.image,
    required this.csvFilePath,
    required this.description,
    required this.color,
    required this.invStartDate,
  }) : super(key: key);

  @override
  State<CoinDetailPage> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  // 날짜 관련
  DateTime? startDate;
  DateTime? endDate;
  DateTime? earliestDate;
  int purchaseDay = 1;

  // CSV -> Map<DateTime, double> (date -> 종가)
  Map<DateTime, double> priceData = {};

  // UI 폼
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  // 계산 결과
  bool showResults = false;
  bool showGraph = false;
  Map<String, dynamic> _investmentResult = {};
  late List<FlSpot> flSpots;
  List<DateTime> sortedDates = [];

  // 로딩 표시
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    startDate = widget.invStartDate;
    endDate = DateTime.now();
    _amountController.text = '100'; // 기본값 100 설정
  }

// FlSpot 리스트로 변환하는 함수
  List<FlSpot> convertPriceDataToFlSpots(Map<DateTime, double> priceData) {
    // 날짜를 정렬
    sortedDates = priceData.keys.toList();

    // 정렬된 날짜를 기반으로 FlSpot 생성
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedDates.length; i++) {
      DateTime date = sortedDates[i];
      double price = priceData[date]!;
      spots.add(FlSpot(i.toDouble(), price));
    }

    return spots;
  }

  // ---------------------------
  // (1) CSV 파일 로드 + 파싱
  // ---------------------------
  Future<void> _loadCsvAndParse() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 1) 파일 읽기
      final csvString = await rootBundle.loadString(widget.csvFilePath);
      // 2) CSV → List<List<dynamic>> 변환
      final List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString, eol: '\n');

      // 첫 행을 헤더로 가정 (ex: ["Date", "Close"])
      // 나머지를 데이터 행으로
      final headers =
          csvTable.first.map((e) => e.toString().trim().toLowerCase()).toList();
      final dataRows = csvTable.skip(1);

      final dateColIndex = headers.indexOf('date');
      final closeColIndex = headers.indexOf('close');

      if (dateColIndex == -1 || closeColIndex == -1) {
        throw Exception("CSV에 'date' 혹은 'close' 헤더가 없습니다.");
      }

      // 3) date/close 컬럼 파싱
      final dateFormatter = DateFormat('yyyy-MM-dd');
      final Map<DateTime, double> parsedData = {};

      for (var row in dataRows) {
        if (row.length <= closeColIndex) continue;
        final dateStr = row[dateColIndex].toString();
        final priceStr = row[closeColIndex].toString();

        if (dateStr.isEmpty || priceStr.isEmpty) continue;
        try {
          final date = dateFormatter.parseStrict(dateStr);
          final price = double.parse(priceStr.replaceAll(',', ''));
          parsedData[date] = price;
        } catch (_) {
          // 파싱 실패한 행은 스킵
        }
      }

      // 4) 파싱 결과를 state에 저장
      setState(() {
        priceData = parsedData;

        // 날짜 범위 세팅
        if (priceData.isNotEmpty) {
          final sortedDates = priceData.keys.toList()..sort();
          earliestDate = sortedDates.first;
          startDate = sortedDates.first;
          endDate = sortedDates.last;
        }
      });
    } catch (e) {
      debugPrint("CSV 로드/파싱 실패: $e");
      showErrorDialog('CSV 파싱에 실패했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ---------------------------
  // (2) 투자 결과 계산
  // ---------------------------
  void calculateInvestmentResults(int amount) {
    if (priceData.isEmpty) {
      showErrorDialog('CSV 데이터가 없습니다. 버튼을 다시 눌러주세요.');
      return;
    }
    if (startDate == null || endDate == null) {
      showErrorDialog('투자 시작일과 종료일을 모두 선택하세요.');
      return;
    }

    final calculator = InvestmentCalculator(priceData: priceData);
    final result = calculator.calculate(
      startDate: startDate!,
      endDate: endDate!,
      purchaseDay: purchaseDay,
      monthlyAmount: amount,
    );

    setState(() {
      _investmentResult = result;
      showResults = true;
    });
  }

  // ---------------------------
  // (3) "투자 결과 계산" 버튼
  // ---------------------------
  Future<void> _onCalculatePressed() async {
    // 폼 검증
    if (!_formKey.currentState!.validate()) return;
    final int amount = int.parse(_amountController.text);

    // ➊ CSV가 아직 파싱 안 되었다면 먼저 로딩/파싱
    if (priceData.isEmpty) {
      await _loadCsvAndParse();
      // 로딩 실패 시 _loadCsvAndParse()에서 showErrorDialog 처리
      // 여기서 종료 가능 (return) -> CSV 실패했으면 계산 불가
      if (priceData.isEmpty) return;
    }

    // ➋ CSV 파싱 완료 후에 계산
    calculateInvestmentResults(amount);
  }

  Future<void> _onCalculateMothlyPressed() async {
    // 폼 검증
    if (!_formKey.currentState!.validate()) return;
    final int amount = int.parse(_amountController.text);

    setState(() {
      showGraph = true;
      //showGraph = !showGraph;
    });
  }

  // ---------------------------
  // 오류 다이얼로그
  // ---------------------------
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        backgroundColor: widget.color,
      ),
      body: Stack(
        children: [
          // 메인 컨텐츠
          _buildMainContent(),

          // 로딩 중일 때 인디케이터
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // (코인 이미지 - Hero)
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Hero(
                  tag: widget.name,
                  child: Image.asset(
                    widget.image,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // 코인 설명
              Text(
                widget.description,
                style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16.0),

              // 투자 시작일 / 종료일 Picker
              // ---------------------------------
              DatePickerRow(
                label: '투자 시작',
                selectedDate: startDate,
                mainColor: widget.color,
                minimumDate: earliestDate,
                onDateSelected: (picked) {
                  setState(() {
                    startDate = picked;
                    if (endDate != null && endDate!.isBefore(startDate!)) {
                      endDate = startDate;
                    }
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DatePickerRow(
                label: '투자 종료',
                selectedDate: endDate,
                mainColor: widget.color,
                minimumDate: startDate,
                onDateSelected: (picked) {
                  setState(() {
                    endDate = picked;
                  });
                },
              ),
              const SizedBox(height: 32.0),

              // 매달 투자할 날짜
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "투자할 날짜 (매달):",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: DropdownButtonFormField<int>(
                      value: purchaseDay,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(31, (i) {
                        final day = i + 1;
                        return DropdownMenuItem(
                          value: day,
                          child: Text('$day일'),
                        );
                      }),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            purchaseDay = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 매달 적립식 금액 (만원)
              Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Text(
                      "적립식 금액 (만원):",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "예: 10",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '금액을 입력하세요';
                        }
                        final amount = int.tryParse(value);
                        if (amount == null) {
                          return '유효한 숫자를 입력하세요';
                        }
                        if (amount <= 0) {
                          return '금액은 1 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              // 결과 계산 버튼
              ElevatedButton(
                onPressed: _onCalculatePressed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: widget.color,
                ),
                child: const Text(
                  "투자 결과 계산",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),

              // 결과 위젯 표시

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                // 애니메이션 시간(필요한 만큼 조절)
                transitionBuilder: (Widget child, Animation<double> animation) {
                  // 여기는 "child가 등장/퇴장할 때" 어떤 애니메이션을 적용할지 정의
                  // 예시1) FadeTransition
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );

                  // 예시2) ScaleTransition
                  // return ScaleTransition(
                  //   scale: animation,
                  //   child: child,
                  // );
                },
                child: showResults
                    ? Column(
                        children: [
                          InvestmentResults(
                            totalInvested:
                                _investmentResult['totalInvested'] ?? 0.0,
                            averagePrice:
                                _investmentResult['averagePrice'] ?? 0.0,
                            coinsPurchased:
                                _investmentResult['coinsPurchased'] ?? 0.0,
                            currentPrice:
                                _investmentResult['currentPrice'] ?? 0.0,
                            currentValue:
                                _investmentResult['currentValue'] ?? 0.0,
                            profitLoss: _investmentResult['profitLoss'] ?? 0.0,
                            titleColor: widget.color,
                            key: const ValueKey('Results'),
                            // AnimatedSwitcher에서 child 위젯을 구분하기 위한 key
                          ),
                          const SizedBox(height: 16.0),

                          // 결과 계산 버튼

                          ElevatedButton(
                            onPressed: _onCalculateMothlyPressed,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 50),
                              backgroundColor: widget.color,
                            ),
                            child: const Text(
                              "그래프 보기",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              showGraph
                                  ? InvestmentLineChart(
                                      investmentSpots:
                                          _investmentResult['investmentSpots'],
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),

                // 보여줄 게 없으면 빈 박스
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// LineChart를 표시하는 위젯
class InvestmentLineChart extends StatelessWidget {
  final List<InvestmentSpot> investmentSpots;

  const InvestmentLineChart({
    Key? key,
    required this.investmentSpots,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // flSpots 생성: InvestmentSpot을 FlSpot으로 변환
    List<FlSpot> flSpots = investmentSpots
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.asset))
        .toList();

    return Column(
      children: [
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true, // 터치를 활성화
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpots) {
                      // touchedSpots에 따라 색상 다르게 줄 수도 있음
                      return Colors.white;
                    },
                    tooltipRoundedRadius: 8.0, // 툴팁 테두리 둥글게
                    tooltipBorder: BorderSide(color: Colors.black, width: 1.5),

                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        // 각 spot(점)에 대한 tooltip 표시 정보를 생성
                        return LineTooltipItem(
                          // 예: "x: 3, y: 5.12" 형식으로 표현
                          '${spot.x.round()}개월\n'
                          '${spot.y.toStringAsFixed(2)}%',
                          const TextStyle(
                            color: Colors.black, // 툴팁 문자 색상
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  // 기타 터치 관련 설정
                  handleBuiltInTouches: true,
                ),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    axisNameWidget: const Text(
                      '누적자산',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    axisNameSize: 30,
                    sideTitles: const SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameSize: 40,
                    axisNameWidget: const Text(
                      '투자기간 (개월)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 6,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < flSpots.length) {
                          return Text('${value.toInt()}');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameSize: 40,
                    axisNameWidget: const Text(
                      '수익률 (%)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    sideTitles: const SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 100,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                minX: 0,
                maxX: flSpots.length.toDouble() - 1,
                minY: -100,
                maxY: (flSpots
                        .map((spot) => spot.y)
                        .reduce((a, b) => a > b ? a : b) +
                    10),
                lineBarsData: [
                  LineChartBarData(
                    spots: flSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.red,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
