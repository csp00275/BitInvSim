// lib/calculator/investment_calculator.dart
import 'package:intl/intl.dart';

/// 투자 계산 로직 담당 클래스
class InvestmentCalculator {
  /// CSV 파싱 후 얻은 날짜별 종가 데이터 (date -> price)
  final Map<DateTime, double> priceData;

  InvestmentCalculator({required this.priceData});

  /// [startDate]부터 [endDate]까지, 매달 [monthlyAmount](만원)를 투자한다고 가정했을 때
  /// 계산 결과(총투자금, 평균가격, 구매코인수, 현재가치, 수익/손실)를 Map으로 반환
  Map<String, double> calculate({
    required DateTime startDate,
    required DateTime endDate,
    required int purchaseDay,
    required int monthlyAmount,
  }) {
    // 투자 기간(개월) 계산
    final int totalMonths = (endDate.year - startDate.year) * 12
        + (endDate.month - startDate.month)
        + 1;

    // 총 투자 금액
    double totalInvested = monthlyAmount.toDouble() * totalMonths;

    // startDate ~ endDate 사이 날짜에 해당하는 price의 평균 계산
    double totalPrice = 0.0;
    int count = 0;
    priceData.forEach((date, price) {
      if (!date.isBefore(startDate) && !date.isAfter(endDate)) {
        totalPrice += price;
        count++;
      }
    });
    double averagePrice = (count > 0) ? (totalPrice / count) : 0.0;

    // 구매한 코인 수
    double coinsPurchased =
    (averagePrice > 0) ? (totalInvested / averagePrice) : 0.0;

    // 투자 종료일 기준 가격 (데이터가 없으면 averagePrice 사용)
    double currentPrice = priceData[endDate] ?? averagePrice;
    // 현재 가치
    double currentValue = coinsPurchased * currentPrice;
    // 수익/손실
    double profitLoss = currentValue - totalInvested;

    return {
      'totalInvested': totalInvested,   // 총 투자금 (만원)
      'averagePrice': averagePrice,     // 평균가격 (원)
      'coinsPurchased': coinsPurchased, // 구매한 코인 수
      'currentPrice': currentPrice,     // 현재(종료일) 가격 (원)
      'currentValue': currentValue,     // 현재 가치 (만원)
      'profitLoss': profitLoss,         // 수익/손실 (만원)
    };
  }
}