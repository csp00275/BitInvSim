// lib/pages/coinDetailPage.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CoinDetailPage extends StatefulWidget {
  final String name;
  final String image;
  final String description;
  final List<Map<String, String>> csvData;
  final Color color;

  CoinDetailPage({
    required this.name,
    required this.image,
    required this.csvData,
    required this.description,
    required this.color,
  });

  @override
  State<CoinDetailPage> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  DateTime? startDate; // 투자 시작 날짜
  DateTime? endDate; // 투자 종료 날짜
  int purchaseDay = 1; // 매수하는 날 (기본값)
  DateTime? earliestDate; // CSV 데이터의 가장 이전 날짜

  Map<DateTime, double> priceData = {}; // 날짜별 가격 데이터

  bool showResults = false; // 결과 창 표시 여부 제어

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePriceData();
  }

  // CSV 데이터를 priceData로 변환하고 가장 이전 날짜 설정
  void _initializePriceData() {
    final dateFormatter = DateFormat('yyyy-MM-dd'); // 날짜 형식 지정

    for (var entry in widget.csvData) {
      // 키를 소문자로 변환하여 일관성 유지
      final Map<String, String> normalizedEntry = {};
      entry.forEach((key, value) {
        normalizedEntry[key.trim().toLowerCase()] = value.trim();
      });

      final dateStr = normalizedEntry['date']; // 'Date'를 소문자로 변경
      final priceStr = normalizedEntry['close']; // 'Close'를 소문자로 변경

      if (dateStr != null && priceStr != null && priceStr.isNotEmpty) {
        try {
          // 명시적으로 날짜 형식 파싱
          final date = dateFormatter.parseStrict(dateStr);
          final price = double.parse(priceStr.replaceAll(',', ''));

          priceData[date] = price; // 정상 데이터 저장
        } catch (e) {
          print("데이터 파싱 실패: $entry, 에러: $e");
        }
      } else {
        print("null 값 또는 비어있는 값: $entry");
      }
    }

    if (priceData.isNotEmpty) {
      final listedDates = priceData.keys.toList()
        ..sort((a, b) => a.compareTo(b));
      setState(() {
        startDate = listedDates.first;
        endDate = listedDates.last;
      });
    } else {
      print("유효한 데이터가 없습니다.");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void calculateInvestmentResults(int amount) {
    if (startDate == null || endDate == null) {
      showErrorDialog('투자 시작일과 종료일을 모두 선택하세요.');
      return;
    }

    // 투자 기간 (개월 단위) 계산
    int totalMonths = (endDate!.year - startDate!.year) * 12 +
        (endDate!.month - startDate!.month) +
        1;

    // 총 투자 금액
    double totalInvested = amount.toDouble() * totalMonths;

    // 투자 기간 동안의 평균 가격 계산
    double totalPrice = 0.0;
    int count = 0;
    for (var entry in priceData.entries) {
      if (entry.key.isAfter(startDate!.subtract(Duration(days: 1))) &&
          entry.key.isBefore(endDate!.add(Duration(days: 1)))) {
        totalPrice += entry.value;
        count++;
      }
    }

    double averagePrice = count > 0 ? totalPrice / count : 0.0;

    // 구매한 코인 수
    double coinsPurchased =
        averagePrice > 0 ? totalInvested / averagePrice : 0.0;

    // 현재 가격 (투자 종료일 기준)
    double currentPrice = priceData[endDate!] ?? averagePrice;

    // 현재 가치
    double currentValue = coinsPurchased * currentPrice;

    // 수익/손실
    double profitLoss = currentValue - totalInvested;

    setState(() {
      showResults = true;
    });

    // 결과를 상태 변수에 저장하거나 별도의 변수에 할당할 수 있습니다.
    // 예: _investmentResult = {...};
  }

  // 날짜 선택 행을 생성하는 공통 함수
  Widget buildDatePickerRow({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    DateTime? minimumDate,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 7, // 텍스트 영역 비율
          child: Text(
            selectedDate == null
                ? "선택 안됨"
                : DateFormat('yyyy-MM').format(selectedDate),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Colors.black, // 텍스트 색상 적용
            ),
          ),
        ),
        Expanded(
          flex: 3, // 버튼 영역 비율
          child: ElevatedButton.icon(
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (_) {
                  final DateTime now = DateTime.now();
                  final DateTime safeMinimumDate =
                      minimumDate ?? DateTime(2000, 1, 1); // 기본 최소 날짜 설정
                  final DateTime initialDate = selectedDate ??
                      (safeMinimumDate.isBefore(now) ? safeMinimumDate : now);

                  return Container(
                    height: 250,
                    color: Colors.white,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initialDate,
                      minimumDate: safeMinimumDate,
                      maximumDate: now,
                      onDateTimeChanged: (DateTime date) {
                        print('${date.year}-${date.month}');
                        onDateSelected(date);
                      },
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.calendar_today,
              color: widget.color, // 아이콘 색상 변경
            ),
            label: Text(
              label,
              style: TextStyle(
                color: Colors.black, // 버튼 텍스트 색상 변경
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // 버튼 색상
              foregroundColor: widget.color, // 버튼 텍스트 및 아이콘 색상
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInvestmentResults(int amount) {
    if (startDate == null || endDate == null) {
      return SizedBox.shrink();
    }

    // 투자 기간 계산 (개월 단위)
    int totalMonths = (endDate!.year - startDate!.year) * 12 +
        (endDate!.month - startDate!.month) +
        1;

    // 총 투자 금액
    double totalInvested = amount.toDouble() * totalMonths;

    // 월별 투자 및 수익 계산 (단순 예시)
    double totalPrice = 0.0;
    int count = 0;
    for (var entry in priceData.entries) {
      if (entry.key.isAfter(startDate!.subtract(Duration(days: 1))) &&
          entry.key.isBefore(endDate!.add(Duration(days: 1)))) {
        totalPrice += entry.value;
        count++;
      }
    }

    double averagePrice = count > 0 ? totalPrice / count : 0.0;
    double coinsPurchased =
        averagePrice > 0 ? totalInvested / averagePrice : 0.0;
    double currentPrice = priceData[endDate!] ?? averagePrice;
    double currentValue = coinsPurchased * currentPrice;
    double profitLoss = currentValue - totalInvested;

    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '투자 결과',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '총 투자 금액: ${totalInvested.toStringAsFixed(2)} 만원',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            Text(
              '평균 구매 가격: ${averagePrice.toStringAsFixed(2)} 원',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            Text(
              '구매한 코인 수: ${coinsPurchased.toStringAsFixed(4)} 개',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            Text(
              '현재 가격: ${currentPrice.toStringAsFixed(2)} 원',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            Text(
              '현재 가치: ${currentValue.toStringAsFixed(2)} 만원',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            Text(
              '수익/손실: ${profitLoss >= 0 ? '+' : ''}${profitLoss.toStringAsFixed(2)} 만원',
              style: TextStyle(
                fontSize: 16.0,
                color: profitLoss >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        centerTitle: true,
        backgroundColor: widget.color, // AppBar 색상 변경
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // 폼 키 할당
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 코인 정보
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.asset(
                    widget.image,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  widget.description,
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                ),
                SizedBox(height: 16.0),

                // 투자 시작 날짜
                buildDatePickerRow(
                  label: "투자 시작",
                  selectedDate: startDate,
                  onDateSelected: (DateTime date) {
                    setState(() {
                      startDate = date;
                      // 투자 종료 날짜의 최소 날짜를 투자 시작 날짜로 설정
                      if (endDate != null && endDate!.isBefore(startDate!)) {
                        endDate = startDate;
                      }
                    });
                  },
                  minimumDate: earliestDate,
                ),
                SizedBox(height: 16.0),

                // 투자 종료 날짜
                buildDatePickerRow(
                  label: "투자 종료",
                  selectedDate: endDate,
                  onDateSelected: (DateTime date) {
                    setState(() {
                      endDate = date;
                    });
                  },
                  minimumDate: startDate,
                ),
                SizedBox(height: 32.0),

                // 투자할 날짜 (매달)
                Row(
                  children: [
                    Expanded(
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(31, (index) {
                          int day = index + 1;
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
                SizedBox(height: 16.0),

                // 얼마씩 할 건지 (만원 단위)
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "적립식 금액 (만원):",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "예: 10",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '금액을 입력하세요';
                          }
                          final int? amount = int.tryParse(value);
                          if (amount == null) {
                            return '유효한 숫자를 입력하세요';
                          }
                          if (amount <= 0) {
                            return '금액은 1 이상이어야 합니다';
                          }
                          // 여기서는 1 이상이면 만원 단위로 간주
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.0),

                // 제출 버튼
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 폼이 유효하면 수행할 작업
                      int amount = int.parse(_amountController.text);
                      // 여기서 amount는 만원 단위의 투자 금액입니다.
                      calculateInvestmentResults(amount);

                      // 추가 로직을 여기에 작성하세요.
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text(
                            '투자 설정이 완료되었습니다.\n'
                            '투자 시작: ${startDate != null ? DateFormat('yyyy-MM').format(startDate!) : "선택 안됨"}\n'
                            '투자 종료: ${endDate != null ? DateFormat('yyyy-MM').format(endDate!) : "선택 안됨"}\n'
                            '투자할 날짜: $purchaseDay 일\n'
                            '투자 금액: ${amount}만원',
                            style: TextStyle(color: Colors.black),
                          ),
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
                  },
                  child: Text(
                    "투자 결과 계산",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // 버튼을 전체 너비로 설정
                    backgroundColor: widget.color, // 버튼 배경색 변경
                  ),
                ),
                if (showResults)
                  buildInvestmentResults(
                    int.parse(_amountController.text),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
