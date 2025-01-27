// lib/utils/investment_utils.dart
import 'package:intl/intl.dart';

class InvestmentData {
  final DateTime date;
  final double cumulativeInvestment;
  final double cumulativeAsset;

  InvestmentData({
    required this.date,
    required this.cumulativeInvestment,
    required this.cumulativeAsset,
  });
}

List<InvestmentData> generateTimeSeriesData(Map<DateTime, double> priceData, int monthlyInvestment) {
  final List<InvestmentData> timeSeriesData = [];
  double cumulativeInvestment = 0;
  double cumulativeAsset = 0;

  final sortedDates = priceData.keys.toList()..sort();

  for (var date in sortedDates) {
    final price = priceData[date]!;
    cumulativeInvestment += monthlyInvestment;
    final coinsPurchased = monthlyInvestment / price;
    cumulativeAsset += coinsPurchased * price;

    timeSeriesData.add(InvestmentData(
      date: date,
      cumulativeInvestment: cumulativeInvestment,
      cumulativeAsset: cumulativeAsset,
    ));
  }

  return timeSeriesData;
}