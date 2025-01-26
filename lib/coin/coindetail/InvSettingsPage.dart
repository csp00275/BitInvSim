import 'package:intl/intl.dart';

/// 연도[year]와 달[month]을 받아 해당 월의 일 수를 반환
int daysInMonth(int year, int month) {
  // 2월 처리 (윤년 여부)
  if (month == 2) {
    final bool isLeapYear =
        (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
    return isLeapYear ? 29 : 28;
  }

  // 31일인 달
  const List<int> months31 = [1, 3, 5, 7, 8, 10, 12];
  if (months31.contains(month)) {
    return 31;
  }

  // 나머지는 30일
  return 30;
}

/// 투자 계산 로직 담당 클래스
class InvestmentCalculator {
  /// CSV 파싱 후 얻은 날짜별 종가 데이터 (date -> price)
  /// - priceData의 값(종가)은 '원' 단위로 가정
  final Map<DateTime, double> priceData;

  InvestmentCalculator({required this.priceData});

  /// [startDate]부터 [endDate]까지,
  /// 매달 [purchaseDay]일에 [monthlyAmount](만원)을 '적립식' 투자한다고 가정했을 때,
  /// 실제로 매달 투자한 코인을 모두 누적하여 최종 결과를 반환.
  ///
  /// - totalInvested: 만원 (투자 총합)
  /// - averagePrice: 원 (실제 매수한 코인들의 평균 매수가)
  /// - coinsPurchased: 총 코인 수 (달마다 산 코인 누적)
  /// - currentPrice: 원 (종료일 시세)
  /// - currentValue: 만원 (총 코인을 종료일 시세로 환산한 결과)
  /// - profitLoss: 만원 (currentValue - totalInvested)
  Map<String, double> calculate({
    required DateTime startDate,
    required DateTime endDate,
    required int purchaseDay,   // 매달 며칠에 투자?
    required int monthlyAmount, // 만원 단위
  }) {
    // ------------------------------
    // 1) 월 단위로 순회하기 위한 준비
    // ------------------------------
    int currentYear = startDate.year;
    int currentMonth = startDate.month;

    final int lastYear = endDate.year;
    final int lastMonth = endDate.month;

    // ------------------------------
    // 2) 누적 변수
    // ------------------------------
    double totalCoins = 0.0;         // 누적 코인 수
    double totalInvestedManny = 0.0; // 누적 투자금 (만원)

    // ------------------------------
    // 3) 월 단위로 반복
    // ------------------------------
    while ((currentYear < lastYear) ||
        (currentYear == lastYear && currentMonth <= lastMonth)) {
      // 3-1) 이 달의 마지막 일 수
      final int dim = daysInMonth(currentYear, currentMonth);

      // 3-2) 만약 purchaseDay가 달의 일 수보다 크면 말일로 보정
      final int finalDay = (purchaseDay > dim) ? dim : purchaseDay;

      // 3-3) 해당 날짜 DateTime
      final DateTime investDate = DateTime(currentYear, currentMonth, finalDay);

      // 3-4) priceData에서 그 날짜 종가(dayPrice) 찾기
      final double? dayPrice = priceData[investDate];

      // 3-5) 데이터가 있으면 투자 진행
      if (dayPrice != null) {
        // 이 달에 투자한 금액(원)
        final double investKRW = monthlyAmount * 10000; // 만원 -> 원
        // 이 달에 매수한 코인 수
        final double monthlyCoins = investKRW / dayPrice;

        // 누적
        totalCoins += monthlyCoins;
        totalInvestedManny += monthlyAmount;
      }

      // 3-6) 다음 달로 이동
      currentMonth++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }
    }

    // ------------------------------
    // 4) 최종 계산
    // ------------------------------
    // 총 투자금 (만원)
    final double totalInvested = totalInvestedManny;

    // 평균매수가(원)
    // (총 투자금(원) / 총 코인 수) = ((totalInvested(만원)*10000) / totalCoins)
    final double averagePrice = (totalCoins > 0)
        ? ((totalInvested * 10000) / totalCoins)
        : 0.0;

    // 구매 코인 수
    final double coinsPurchased = totalCoins;

    // 현재 가격(원) (없으면 averagePrice 사용)
    final double currentPrice = priceData[endDate] ?? averagePrice;

    // 현재 가치(만원) = (코인 수 × 종료일 시세(원)) / 10000
    final double currentValue =
        (coinsPurchased * currentPrice) / 10000.0;

    // 수익/손실(만원)
    final double profitLoss = currentValue - totalInvested;

    // ------------------------------
    // 5) 결과 반환
    // ------------------------------
    return {
      'totalInvested': totalInvested,   // 총 투자금 (만원)
      'averagePrice': averagePrice,     // 평균매수가 (원)
      'coinsPurchased': coinsPurchased, // 누적 코인 수
      'currentPrice': currentPrice,     // 현재(종료일) 가격 (원)
      'currentValue': currentValue,     // 현재 가치 (만원)
      'profitLoss': profitLoss,         // 수익/손실 (만원)
    };
  }
}