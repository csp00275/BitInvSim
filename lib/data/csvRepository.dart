import 'dart:io';
import 'dart:convert'; // jsonDecode 사용
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// 업비트 마켓 코드 매핑 (coinName -> KRW-???)
final Map<String, String> marketMapping = {
  'Bitcoin': 'KRW-BTC',
  'Ethereum': 'KRW-ETH',
  'Solana': 'KRW-SOL',
  'Doge': 'KRW-DOGE',
  'Tron': 'KRW-TRX',
  'Ripple': 'KRW-XRP',
};

/// 로컬 저장소의 파일 경로 반환
Future<String> getLocalFilePath(String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/$filename';
}

/// assets의 CSV 파일을 로컬로 복사 (처음 한 번만 필요)
Future<File> copyAssetCsvToLocal(String assetPath, String filename) async {
  final data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List();
  final path = await getLocalFilePath(filename);
  return File(path).writeAsBytes(bytes, flush: true);
}

/// (옵션) CSV 파일 전체 내용 콘솔 출력 (디버깅용)
Future<void> printCsvFile(String filename) async {
  final localPath = await getLocalFilePath(filename);
  final file = File(localPath);
  if (await file.exists()) {
    final content = await file.readAsString();
    print("CSV 파일 내용($filename):\n$content");
  } else {
    print("CSV 파일이 존재하지 않습니다: $filename");
  }
}

/// 실제 업비트 API 호출용 함수: 응답 전체를 문자열로 반환
Future<String> fetchUpbitCandles({
  required String marketCode,
  required DateTime fetchTo,
  required int count,
}) async {
  // Upbit 일봉 API는 "to"를 yyyy-MM-dd'T'HH:mm:ss 형식으로 넣어야 하며, HH:mm:ss = 09:00:00
  final toParam = DateFormat("yyyy-MM-dd'T'09:00:00").format(fetchTo);
  final apiUrl =
      "https://api.upbit.com/v1/candles/days?market=$marketCode&count=$count&to=$toParam";

  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception("Upbit API 요청 실패: ${response.statusCode}, url=$apiUrl");
  }
}

/// CSV 파일을 읽고 마지막 날짜를 확인한 후, 필요한 부분만 API로 받아서 "yyyy-MM-dd,숫자" 형식으로 Append
Future<void> updateCsvIfNeeded({
  required String assetPath,  // 예: 'assets/csv/btc.csv'
  required String filename,   // 예: 'btc.csv'
  required String coinName,   // 예: 'Bitcoin'
}) async {
  final localPath = await getLocalFilePath(filename);
  final localFile = File(localPath);

  // 1) 로컬 파일이 없으면 assets에서 복사
  if (!await localFile.exists()) {
    await copyAssetCsvToLocal(assetPath, filename);
    print("처음 실행으로 인해 assets -> 로컬 복사 완료: $filename");
  }

  // 2) CSV 파일 읽기
  final csvContent = await localFile.readAsString();
  final rows = csvContent.split('\n').where((row) => row.trim().isNotEmpty).toList();
  if (rows.isEmpty) {
    print("CSV에 데이터가 없습니다. (헤더만 있을 수도) -> 업데이트 종료");
    return;
  }

  // 첫 줄은 헤더라고 가정 ("Date,Close")
  // 마지막 줄이 실제 데이터 행
  final lastDataRow = rows.last;
  final columns = lastDataRow.split(',');
  if (columns.length < 2) {
    print("CSV 마지막 행의 형식이 잘못됨: $lastDataRow");
    return;
  }

  final lastDateStr = columns[0].trim(); // ex) "2019-01-14"
  DateTime lastDate;
  try {
    lastDate = DateTime.parse(lastDateStr);
  } catch (e) {
    print("날짜 파싱 오류: $e (row=$lastDataRow)");
    return;
  }

  // 3) Upbit은 오전 9시 기준이므로, 현재 시간이 9시 전이면 전날 날짜로 todayDate
  final now = DateTime.now();
  final todayDate = now.hour < 9
      ? DateTime(now.year, now.month, now.day - 1)
      : DateTime(now.year, now.month, now.day);

  // 이미 최신 데이터이면 return
  if (!lastDate.isBefore(todayDate)) {
    print("CSV 데이터가 최신입니다. (마지막: $lastDateStr)");
    return;
  }

  final missingStart = lastDate.add(const Duration(days: 1));
  final missingEnd = todayDate;

  // 코인 이름 -> Upbit 마켓 코드
  final marketCode = marketMapping[coinName] ?? 'KRW-BTC';

  print("CSV 업데이트 시작: $coinName ($marketCode), 기존 마지막=$lastDateStr, "
      "추가 구간: $missingStart ~ $missingEnd");

  // 새로 받을 행들 (오름차순)
  List<String> newRows = [];

  // 4) Upbit API 반복 호출 (최대 200일씩)
  DateTime fetchTo = missingEnd;
  while (!fetchTo.isBefore(missingStart)) {
    // API 호출 (count=200)
    String responseBody;
    try {
      responseBody = await fetchUpbitCandles(
        marketCode: marketCode,
        fetchTo: fetchTo,
        count: 200,
      );
    } catch (e) {
      print("업데이트 도중 API 에러: $e");
      break;
    }

    final List<dynamic> data = jsonDecode(responseBody);
    if (data.isEmpty) {
      print("받은 데이터가 없음( $fetchTo )");
      break;
    }

    // 최신 → 과거 순이므로, reverse()해서 과거 → 최신 순으로 변환
    final candles = data.reversed.toList();

    // 날짜 범위에 맞춰 Date,Close 행 생성
    for (var candle in candles) {
      final candleDateStr = candle["candle_date_time_kst"] as String;
      final candleDateTime = DateTime.parse(candleDateStr);
      final onlyDate = DateTime(candleDateTime.year, candleDateTime.month, candleDateTime.day);

      // 해당 일봉이 missingStart ~ missingEnd 범위 내인지 체크
      if (onlyDate.isBefore(missingStart) || onlyDate.isAfter(missingEnd)) {
        continue; // 범위 밖이면 스킵
      }
      final closePrice = candle["trade_price"]; // 종가

      // "yyyy-MM-dd,closePrice" 문자열
      final rowStr = "${DateFormat('yyyy-MM-dd').format(onlyDate)},$closePrice";
      newRows.add(rowStr);
    }

    // 새로 추가할 행이 없으면 break
    if (newRows.isEmpty) {
      break;
    }

    // candles 중 가장 오래된 날짜 -> fetchTo = 그 전날
    final oldestCandleStr = candles.first["candle_date_time_kst"] as String;
    final oldestCandleDT = DateTime.parse(oldestCandleStr);
    fetchTo = oldestCandleDT.subtract(const Duration(days: 1));

    // API 호출 사이에 작은 지연
    await Future.delayed(const Duration(milliseconds: 500));

    // 범위를 넘어가면 중단
    if (fetchTo.isBefore(missingStart)) break;
  }

  // 5) 새로 받은 데이터가 있다면 CSV 파일에 Append
// 5) 새로 받은 데이터가 있다면 CSV 파일에 Append
  if (newRows.isNotEmpty) {
    // 이미 오름차순(가장 오래된→가장 최신)으로 정렬되어 있음
    final appendedContent = "\n" + newRows.join("\n");
    await localFile.writeAsString(appendedContent, mode: FileMode.append, flush: true);
    print("CSV 파일에 ${newRows.length}개의 새 행을 추가했습니다. (파일: $filename)");
    print("추가된 행들:\n${newRows.join("\n")}");
  } else {
    print("추가로 업데이트할 데이터가 없습니다.");
  }


}