/// 연도[year]와 달[month]를 받아 해당 월의 일 수를 반환
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
  final int month; // 투자한 월 (예: 0, 1, 2, ...)
  final double asset; // 해당 시점의 수익률 (%)

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

/// 투자 계산 로직 담당 클래스 (구매일 시세를 평가 시점으로 사용)
class InvestmentCalculator {
  /// CSV 파싱 후 얻은 날짜별 종가 데이터 (date -> price)
  /// - priceData의 값(종가)는 '원' 단위로 가정
  final Map<DateTime, double> priceData;

  InvestmentCalculator({required this.priceData});

  Map<String, dynamic> calculate({
    required DateTime startDate,
    required DateTime endDate,
    required int purchaseDay, // 매달 몇 일에 투자할 것인가?
    required int monthlyAmount, // 투자 금액 (만원 단위)
  }) {
    // ------------------------------
    // (1) 반복 범위 준비
    // ------------------------------
    int currentYear = startDate.year;
    int currentMonth = startDate.month;
    final int lastYear = endDate.year;
    final int lastMonth = endDate.month;

    // ------------------------------
    // (2) 누적 변수 (글로벌 누적 변수)
    // ------------------------------
    double totalCoins = 0.0; // 누적 코인 수
    double totalInvestedManny = 0.0; // 누적 투자금 (만원)

    // 최종 결과 변수 (while 루프 내에서 매월 업데이트)
    double averageBuyPrice = 0.0; // 평균 매수가 (원)
    double currentPrice = 0.0; // 평가 시 사용한 시세 (원)
    double currentValue = 0.0; // 현재 평가액 (만원)
    double profitLoss = 0.0; // 수익/손실 (만원)
    double profitPercent = 0.0; // 수익률 (%)

    // "월별 그래프"용 저장 (각 달의 수익률 기록)
    List<InvestmentSpot> investmentSpots = [];
    int loopCount = 0;

    // ------------------------------
    // (3) 월 단위로 반복하며 계산
    // ------------------------------
    while ((currentYear < lastYear) ||
        (currentYear == lastYear && currentMonth <= lastMonth)) {
      // 구매일 결정: 사용자가 입력한 purchaseDay가 해당 월의 최대일보다 크면 마지막 날로 조정
      final int dim = daysInMonth(currentYear, currentMonth);
      final int finalDay = (purchaseDay > dim) ? dim : purchaseDay;
      final DateTime buyDate = DateTime(currentYear, currentMonth, finalDay);

      // 구매 진행 (매달 구매 진행)
      final double? dayPrice = priceData[buyDate];
      if (dayPrice == null) {
        print(
            "[$currentYear-$currentMonth] 데이터 누락: buyDate $buyDate (dayPrice null)");
        // 해당 달은 구매/평가 건너뜀
      } else {
        final double investKRW = monthlyAmount * 10000; // 만원을 원으로 변환
        final double monthlyCoins = investKRW / dayPrice;
        totalCoins += monthlyCoins;
        totalInvestedManny += monthlyAmount;
      }

      // 평가: 구매일의 시세(dayPrice)를 그대로 사용하여 평가
      if (dayPrice == null) {
        print("[$currentYear-$currentMonth] 평가 불가 (데이터 누락)");
      } else {
        currentPrice = dayPrice;
        if (totalCoins > 0) {
          averageBuyPrice = (totalInvestedManny * 10000) / totalCoins;
        } else {
          averageBuyPrice = 0.0;
        }
        currentValue = (totalCoins * currentPrice) / 10000.0;
        profitLoss = currentValue - totalInvestedManny;
        if (totalInvestedManny > 0) {
          profitPercent = (profitLoss / totalInvestedManny) * 100.0;
        } else {
          profitPercent = 0.0;
        }
        // 첫 달은 초기 상태이므로 수익률 0% 강제
        if (loopCount == 0) {
          profitPercent = 0.0;
        }
        profitPercent = double.parse(profitPercent.toStringAsFixed(2));

        // 디버그 로그 출력

        // InvestmentSpot 추가 (x축은 loopCount, 즉 투자 진행 순서)
        investmentSpots.add(
          InvestmentSpot(
            month: loopCount,
            asset: profitPercent,
          ),
        );
      }

      // 다음 달로 진행
      currentMonth++;
      loopCount++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }
    }

    // ------------------------------
    // (4) 최종 계산: 마지막 달의 구매일 시세를 기준으로 평가
    // ------------------------------
    final double totalInvested = totalInvestedManny;
    if (totalCoins > 0) {
      averageBuyPrice = (totalInvestedManny * 10000) / totalCoins;
    } else {
      averageBuyPrice = 0.0;
    }
    // 마지막 달의 구매일을 재계산 (endDate의 연,월 기준)
    final int finalDim = daysInMonth(endDate.year, endDate.month);
    final int finalBuyDay = (purchaseDay > finalDim) ? finalDim : purchaseDay;
    final DateTime finalBuyDate =
        DateTime(endDate.year, endDate.month, finalBuyDay);
    final double finalPrice = priceData[finalBuyDate] ?? averageBuyPrice;
    final double finalCurrentValue = (totalCoins * finalPrice) / 10000.0;
    final double finalProfitLoss = finalCurrentValue - totalInvested;

    return {
      'totalInvested': totalInvested, // 만원
      'averagePrice': averageBuyPrice, // 원 (평균 매수가)
      'coinsPurchased': totalCoins,
      'currentPrice': finalPrice, // 원
      'currentValue': finalCurrentValue, // 만원
      'profitLoss': finalProfitLoss, // 만원
      'profitPercent': profitPercent, // % (누적 수익률)
      'investmentSpots': investmentSpots,
    };
  }
}
