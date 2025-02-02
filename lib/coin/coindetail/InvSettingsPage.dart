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

class InvestmentSpot {
  final int month; // 투자한 월 (예: 1, 2, ..., 12)
  final double asset; // 해당 시점의 자산 (만원)

  InvestmentSpot({
    required this.month,
    required this.asset,
  });
}

class InvestmentResult {
  final double totalInvested;
  final double averagePrice;
  final double coinsPurchased;
  final double currentPrice;
  final double currentValue;
  final double profitLoss;
  final List<InvestmentSpot> investmentSpots;

  InvestmentResult({
    required this.totalInvested,
    required this.averagePrice,
    required this.coinsPurchased,
    required this.currentPrice,
    required this.currentValue,
    required this.profitLoss,
    required this.investmentSpots,
  });
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
  Map<String, dynamic> calculate({
    required DateTime startDate,
    required DateTime endDate,
    required int purchaseDay, // 매달 며칠에 투자?
    required int monthlyAmount, // 만원 단위
  }) {
    // ------------------------------
    // (1) 반복범위 준비
    // ------------------------------
    int currentYear = startDate.year;
    int currentMonth = startDate.month;

    final int lastYear = endDate.year;
    final int lastMonth = endDate.month;

    // ------------------------------
    // (2) 누적 변수
    // ------------------------------
    double totalCoins = 0.0; // 누적 코인 수
    double totalInvestedManny = 0.0; // 누적 투자금 (만원)

    // "월별 그래프"용 저장
    List<InvestmentSpot> investmentSpots = [];
    int loopCount = 0;

    // ------------------------------
    // (3) 월 단위로 반복
    //     => 마지막 달까지 포함하려면 <= 조건
    // ------------------------------
    while ((currentYear < lastYear) ||
        (currentYear == lastYear && currentMonth <= lastMonth)) {
      // ------------------------------------------------
      // (3-1) "매수 로직": 이 달에 실제로 매수하는 날짜 = buyDate
      // ------------------------------------------------
      final int dim = daysInMonth(currentYear, currentMonth);
      final int finalDay = (purchaseDay > dim) ? dim : purchaseDay;
      final DateTime buyDate = DateTime(currentYear, currentMonth, finalDay);

      // priceData에서 구매일 시세 가져오기
      final double? dayPrice = priceData[buyDate];
      if (dayPrice != null) {
        // 매수
        final double investKRW = monthlyAmount * 10000; // 만원 -> 원
        final double monthlyCoins = investKRW / dayPrice;

        totalCoins += monthlyCoins;
        totalInvestedManny += monthlyAmount;
      }

      // ------------------------------------------------
      // (3-2) "평가 로직": 이 달 말일 시세로 내 자산 평가
      // ------------------------------------------------
      // 말일 구하기
      final int lastDayOfMonth = daysInMonth(currentYear, currentMonth);
      final DateTime monthlyCloseDate =
          DateTime(currentYear, currentMonth, lastDayOfMonth);

      double? monthlyClosePrice = priceData[monthlyCloseDate];
      // 만약 null이면, 직전 영업일 등을 찾아야 하지만 여기서는 생략
      if (monthlyClosePrice == null) {
        monthlyClosePrice = 0.0;
      }

      // 달 말일 기준: 내 총자산(만원)
      final double monthlyValue = (totalCoins * monthlyClosePrice) / 10000.0;

      // “내가 지금까지 투자한 금액(만원)” = totalInvestedManny
      // 수익(또는 손실) = (monthlyValue - totalInvestedManny)
      // 수익률(%) = ((monthlyValue - totalInvestedManny) / totalInvestedManny)*100
      double profitPercent = 0;
      if (totalInvestedManny > 0) {
        profitPercent =
            ((monthlyValue - totalInvestedManny) / totalInvestedManny) * 100.0;
      }

      // 소수점 자리수 정리(필요하다면)
      profitPercent = double.parse(profitPercent.toStringAsFixed(2));

      // (3-3) 그래프 데이터를 쌓는다
      //   month: 몇 번째 달인지
      //   asset: 여기서는 "수익률(%)"를 예시로 저장
      investmentSpots.add(
        InvestmentSpot(
          month: loopCount,
          asset: profitPercent,
        ),
      );

      // ------------------------------
      // (3-4) 다음 달로
      // ------------------------------
      currentMonth++;
      loopCount++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }
    }

    // ------------------------------
    // (4) 최종 계산
    // ------------------------------
    // totalInvestedManny(만원) = 그동안 투자한 총액
    final double totalInvested = totalInvestedManny;

    // 코인을 하나도 못 샀으면 모두 0
    double averagePrice = 0.0;
    if (totalCoins > 0) {
      // (총 투자금(원) / 총 코인)
      averagePrice = (totalInvestedManny * 10000) / totalCoins;
    }
    // 종료일 시세
    final double currentPrice = priceData[endDate] ?? averagePrice;
    // 현재 가치(만원)
    final double currentValue = (totalCoins * currentPrice) / 10000.0;
    // 수익/손실(만원)
    final double profitLoss = currentValue - totalInvested;

    // ------------------------------
    // (5) 결과 반환
    // ------------------------------
    return {
      'totalInvested': totalInvested, // 만원
      'averagePrice': averagePrice, // 원
      'coinsPurchased': totalCoins,
      'currentPrice': currentPrice, // 원
      'currentValue': currentValue, // 만원
      'profitLoss': profitLoss, // 만원
      'investmentSpots': investmentSpots,
    };
  }
}
