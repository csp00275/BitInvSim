// lib/widgets/investment_results.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 세 자리 콤마 표기용

/// 투자 결과를 표시하는 위젯
class InvestmentResults extends StatelessWidget {
  final double totalInvested; // 총 투자금 (만원)
  final double averagePrice; // 평균 구매가 (원)
  final double coinsPurchased; // 구매한 코인 수
  final double currentPrice; // 현재 가격 (원)
  final double currentValue; // 현재 가치 (만원)
  final double profitLoss; // 수익/손실 (만원)
  final Color titleColor;

  const InvestmentResults({
    Key? key,
    required this.totalInvested,
    required this.averagePrice,
    required this.coinsPurchased,
    required this.currentPrice,
    required this.currentValue,
    required this.profitLoss,
    this.titleColor = Colors.black,
  }) : super(key: key);

  /// 세 자리 콤마(1,234 등) 붙여주는 헬퍼
  String _comma(int number) {
    return NumberFormat.decimalPattern('ko').format(number);
  }

  /// 만원 단위의 값 [manValue]를 받아,
  /// - 1억 이상이면 "X억 Y,YYY만원"
  /// - 딱 떨어지면 "X억"
  /// - 1억 미만이면 "Y,YYY만원"
  /// - 음수면 앞에 '-' 붙이기
  String formatManToEokDetailed(double manValue) {
    int absInt = manValue.abs().round();
    final sign = (manValue < 0) ? '-' : '';

    int eokPart = absInt ~/ 10000; // 정수 나눗셈
    int manPart = absInt % 10000; // 나머지

    if (eokPart > 0 && manPart > 0) {
      // 예: 12500 → "1억 2,500만원"
      return '$sign${_comma(eokPart)}억 ${_comma(manPart)}만원';
    } else if (eokPart > 0 && manPart == 0) {
      // 예: 20000 → "2억"
      return '$sign${_comma(eokPart)}억';
    } else {
      // 억 미만일 경우
      return '$sign${_comma(manPart)}만원';
    }
  }

  Widget buildResultRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? fontWeight, // 추가된 매개변수
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 라벨
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 값 (오른쪽 정렬)
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20.0,
                color: valueColor ?? Colors.black,
                fontWeight: fontWeight ?? FontWeight.normal, // 적용
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --------------------
    // 1) 평균 구매가격 처리
    // --------------------
    bool isAvgPriceBelow1Man = (averagePrice < 10000);
    late String averagePriceStr;
    late String coinsPurchasedStr;
    late String currentPriceStr;

    // 2) 현재 가격(만원 변환) + 기타
    // --------------------
    final double currPriceInMan = currentPrice / 10000.0;
    final String totalInvestedStr = formatManToEokDetailed(totalInvested);
    final String currentValueStr = formatManToEokDetailed(currentValue);

    if (isAvgPriceBelow1Man) {
      // 평균가 1만원 미만 → 원 단위 표기 ("X,XXX원"), 코인 수도 정수로 콤마 ("X,XXX개")
      averagePriceStr = '${_comma(averagePrice.round())}원';
      coinsPurchasedStr = '${_comma(coinsPurchased.round())} 개';
      currentPriceStr = '${_comma(currentPrice.round())}원';
    } else {
      // 기존 로직 (만원 단위 변환 + 억 변환)
      final double avgPriceInMan = averagePrice / 10000.0;
      averagePriceStr = formatManToEokDetailed(avgPriceInMan);
      currentPriceStr = formatManToEokDetailed(currPriceInMan);

      // 코인 수는 소수점 4자리
      coinsPurchasedStr = '${coinsPurchased.toStringAsFixed(4)} 개';
    }

    // --------------------

    // 수익/손실 (+/-)
    final sign = (profitLoss >= 0) ? '+' : '';
    final profitLossStr = '$sign${formatManToEokDetailed(profitLoss)}';
    final profitLossPer = (profitLoss / totalInvested) * 100;
    final profitLossPerStr = '$sign${profitLossPer.toStringAsFixed(2)}%';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '투자 결과',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8.0),

          // 총 투자 금액
          buildResultRow(
            '총 투자 금액:',
            totalInvestedStr,
          ),
          // 평균 구매 가격
          buildResultRow(
            '평균 구매 가격:',
            averagePriceStr,
          ),
          // 구매한 코인 수
          buildResultRow(
            '구매한 코인 수:',
            coinsPurchasedStr,
          ),
          // 현재 가격
          buildResultRow(
            '코인 가격:',
            currentPriceStr,
          ),
          // 현재 가치
          buildResultRow(
            '평가 가치:',
            currentValueStr,
          ),

          // 수익/손실 (볼드 적용)
          buildResultRow(
            '수익/손실:',
            profitLossStr,
            valueColor: (profitLoss >= 0) ? Colors.green.shade700 : Colors.red,
            fontWeight: FontWeight.bold, // 볼드 적용
          ),
          // 수익률/손실률 (볼드 적용)
          buildResultRow(
            '수익률/손실률:',
            profitLossPerStr,
            valueColor: (profitLoss >= 0) ? Colors.green.shade700 : Colors.red,
            fontWeight: FontWeight.bold, // 볼드 적용
          ),
        ],
      ),
    );
  }
}
