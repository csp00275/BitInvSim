// lib/widgets/investment_results.dart
import 'package:flutter/material.dart';

/// 투자 결과를 표시하는 위젯
class InvestmentResults extends StatelessWidget {
  final double totalInvested;
  final double averagePrice;
  final double coinsPurchased;
  final double currentPrice;
  final double currentValue;
  final double profitLoss;
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

  /// 개별 항목을 표시하는 Row 생성
  Widget buildResultRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 라벨
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          // 값
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8.0),
            buildResultRow('총 투자 금액:', '${totalInvested.toStringAsFixed(2)} 만원'),
            buildResultRow('평균 구매 가격:', '${averagePrice.toStringAsFixed(2)} 원'),
            buildResultRow('구매한 코인 수:', '${coinsPurchased.toStringAsFixed(4)} 개'),
            buildResultRow('현재 가격:', '${currentPrice.toStringAsFixed(2)} 원'),
            buildResultRow('현재 가치:', '${currentValue.toStringAsFixed(2)} 만원'),
            buildResultRow(
              '수익/손실:',
              '${profitLoss >= 0 ? '+' : ''}${profitLoss.toStringAsFixed(2)} 만원',
              valueColor: profitLoss >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}