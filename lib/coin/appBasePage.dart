import 'dart:async';
import 'package:bit_invest_sim/Settings.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/coin_data.dart';
import 'coinDetailPage.dart';
import '';

class AppBasePage extends StatefulWidget {
  @override
  _AppBasePageState createState() => _AppBasePageState();
}

class _AppBasePageState extends State<AppBasePage> {
  Future<List<Map<String, String>>> readCsvData(String filePath) async {
    try {
      final csvString = await rootBundle.loadString(filePath);
      final rows = const CsvToListConverter().convert(csvString, eol: '\n');

      // 첫 번째 행은 헤더로 사용
      final headers = rows.first.cast<String>();
      final data = rows.skip(1).map((row) {
        // 각각의 요소를 String으로 변환
        final rowAsString = row.map((item) => item.toString()).toList();
        return Map<String, String>.fromIterables(headers, rowAsString);
      }).toList();

      return data;
    } catch (e) {
      print("CSV 읽기 실패: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('적립식 투자 시뮬레이션'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 클릭 시 이동할 페이지로 네비게이션
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: coinData.length,
          itemBuilder: (context, index) {
            final coin = coinData[index];
            return GestureDetector(
              onTap: () async {
                try {
                  print("CSV 파일 읽기 시작: ${coin['csv']}");
                  // CSV 데이터 읽기
                  final csvData = await readCsvData(coin['csv']!);
                  print("CSV 데이터 로드 성공: $csvData");

                  print(csvData); // 여기서 CSV 데이터를 출력하거나 활용 가능

                  // 새로운 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoinDetailPage(
                        name: coin['name']!,
                        image: coin['image']!,
                        description: coin['description']!,
                        csvFilePath: coin['csv']!,
                        color: coin['color']!, // CSV 데이터 전달
                        invStartDate: coin['startDate']!,
                      ),
                    ),
                  );
                } catch (e) {
                  print("오류 발생: $e");
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Hero(
                          tag: coin['name']!,
                          child: Image.asset(
                            coin['image']!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coin['name']!,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              coin['description']!,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
