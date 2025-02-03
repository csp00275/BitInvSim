import 'dart:io';

import 'package:bit_invest_sim/data/csv_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart'; // CSV 파싱
import 'package:intl/intl.dart';
import 'dart:math' as math;

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
    super.key,
    required this.name,
    required this.image,
    required this.csvFilePath,
    required this.description,
    required this.color,
    required this.invStartDate,
  });

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

  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    startDate = widget.invStartDate;
    DateTime now = DateTime.now();
    endDate = now.hour < 9
        ? DateTime(now.year, now.month, now.day - 1)
        : DateTime(now.year, now.month, now.day);
    _amountController.text = '100'; // 기본값 100 설정
    // CSV 데이터를 업데이트해야 하는 경우
    updateCsvIfNeeded(
      assetPath: widget.csvFilePath, // 예: 'assets/csv/btc.csv'
      filename: widget.csvFilePath.split('/').last, // 예: 'btc.csv'
      coinName: widget.name, // 예: 'Bitcoin'
    );
  }

  @override
  void dispose() {
    // 메모리 누수를 막기 위해 dispose 필요
    _scrollController.dispose();
    super.dispose();
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
      // assets 대신 로컬 파일에서 CSV 읽기
      final localPath =
          await getLocalFilePath(widget.csvFilePath.split('/').last);
      final csvString = await File(localPath).readAsString();
      // 나머지 파싱 로직은 그대로...
      final List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString, eol: '\n');

      final headers =
          csvTable.first.map((e) => e.toString().trim().toLowerCase()).toList();
      final dataRows = csvTable.skip(1);

      final dateColIndex = headers.indexOf('date');
      final closeColIndex = headers.indexOf('close');

      if (dateColIndex == -1 || closeColIndex == -1) {
        throw Exception("CSV에 'date' 혹은 'close' 헤더가 없습니다.");
      }

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

      setState(() {
        priceData = parsedData;
        if (priceData.isNotEmpty) {
          final sortedDates = priceData.keys.toList();
          earliestDate ??= sortedDates.first;
          startDate ??= sortedDates.first;
          endDate ??= sortedDates.last;
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
    if (!_formKey.currentState!.validate()) return;
    final int amount = int.parse(_amountController.text);

    // 1) CSV 데이터 업데이트 (업데이트가 필요한 경우)
    await updateCsvIfNeeded(
      assetPath: widget.csvFilePath,
      filename: widget.csvFilePath.split('/').last,
      coinName: widget.name,
    );

    // 2) 업데이트 후, 최신 CSV 데이터를 로컬 파일에서 재파싱하여 priceData 갱신
    await _loadCsvAndParse();
    if (priceData.isEmpty) {
      showErrorDialog('CSV 데이터를 로드하지 못했습니다.');
      return;
    }

    // 3) 최신 데이터 기반으로 투자 결과 계산
    calculateInvestmentResults(amount);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onCalculateMothlyPressed() async {
    // 폼 검증
    if (!_formKey.currentState!.validate()) return;

    // CSV 업데이트가 필요하다면 업데이트 후 재파싱 (선택 사항)
    // 만약 _onCalculatePressed에서 이미 최신 데이터로 파싱을 완료했다면 이 단계는 생략할 수 있습니다.
    await updateCsvIfNeeded(
      assetPath: widget.csvFilePath,
      filename: widget.csvFilePath.split('/').last,
      coinName: widget.name,
    );
    await _loadCsvAndParse(); // 최신 CSV 데이터를 다시 파싱하여 priceData 갱신

    // 만약 투자 결과 계산이 CSV 데이터 변경에 따라 달라진다면, 계산 결과도 다시 계산
    // 여기서는 그래프 데이터 생성만 업데이트한다고 가정
    final calculator = InvestmentCalculator(priceData: priceData);
    // 투자 결과 계산은 필요한 경우 _investmentResult를 재계산 (예: 시작일, 종료일, 투자일 등)
    final result = calculator.calculate(
      startDate: startDate!,
      endDate: endDate!,
      purchaseDay: purchaseDay,
      monthlyAmount: int.parse(_amountController.text),
    );
    setState(() {
      _investmentResult = result;
      showGraph = true;
    });

    // 그래프 데이터를 재계산할 때 convertPriceDataToFlSpots() 등 호출 가능
    flSpots = convertPriceDataToFlSpots(priceData);

    // 스크롤 애니메이션: 그래프가 나타난 후 화면 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), // 애니메이션 시간
          curve: Curves.easeOut,
        );
      }
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
        title: Text(
          widget.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: widget.color.computeLuminance() > 0.3
                ? Colors.black
                : Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: widget.color,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
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
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[700],
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // (코인 이미지 - Hero)

                    // 투자 시작일 / 종료일 Picker
                    // ---------------------------------
                    DatePickerRow(
                      label: '투자 시작',
                      selectedDate: startDate,
                      mainColor: widget.color,
                      minimumDate: widget.invStartDate,
                      // 기본 최소 날짜 설정

                      onDateSelected: (picked) {
                        setState(() {
                          startDate = picked;
                          if (endDate != null &&
                              endDate!.isBefore(startDate!)) {
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
                        minimumSize: const Size(200, 50),
                        backgroundColor: widget.color,
                        elevation: 3.0,
                      ),
                      child: Text(
                        "투자 결과 계산",
                        style: TextStyle(
                          fontWeight: widget.color.computeLuminance() > 0.3
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: widget.color.computeLuminance() > 0.3
                              ? Colors.black
                              : Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),

                    // 결과 위젯 표시

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      // 애니메이션 시간(필요한 만큼 조절)
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
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
                                      _investmentResult['coinsPurchased'] ??
                                          0.0,
                                  currentPrice:
                                      _investmentResult['currentPrice'] ?? 0.0,
                                  currentValue:
                                      _investmentResult['currentValue'] ?? 0.0,
                                  profitLoss:
                                      _investmentResult['profitLoss'] ?? 0.0,
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
                                    elevation: 3.0,
                                  ),
                                  child: Text(
                                    "그래프 보기",
                                    style: TextStyle(
                                      fontWeight:
                                          widget.color.computeLuminance() > 0.3
                                              ? FontWeight.w500
                                              : FontWeight.w700,
                                      color:
                                          widget.color.computeLuminance() > 0.3
                                              ? Colors.black
                                              : Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                                showGraph
                                    ? const SizedBox.shrink()
                                    : const SizedBox(height: 32.0),
                                Column(
                                  children: [
                                    showGraph
                                        ? InvestmentLineChart(
                                            investmentSpots: _investmentResult[
                                                'investmentSpots'],
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
          ],
        ),
      ),
    );
  }
}

/// LineChart를 표시하는 위젯
class InvestmentLineChart extends StatelessWidget {
  final List<InvestmentSpot> investmentSpots;

  const InvestmentLineChart({
    super.key,
    required this.investmentSpots,
  });

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
                    tooltipBorder:
                        const BorderSide(color: Colors.black, width: 1.5),

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
                  topTitles: const AxisTitles(
                    axisNameWidget: Text(
                      '투자기간 별 수익률',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    axisNameSize: 30,
                    sideTitles: SideTitles(showTitles: false),
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
                  leftTitles: const AxisTitles(
                    axisNameSize: 40,
                    axisNameWidget: Text(
                      '수익률 (%)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval:
                            flSpots.map((spot) => spot.y).reduce(math.max) >
                                    1000.0
                                ? 500.0
                                : 100.0),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                minX: 0,
                maxX: flSpots.length.toDouble() - 1,
                minY: -100,
                maxY: (flSpots.map((spot) => spot.y).reduce(math.max) / 100)
                        .ceil() *
                    100.0,
                lineBarsData: [
                  LineChartBarData(
                    spots: flSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.red,
                    dotData: const FlDotData(show: true),
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
