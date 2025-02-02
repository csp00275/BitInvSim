// lib/data/coin_data.dart

import 'package:flutter/material.dart';

final List<Map<String, dynamic>> coinData = [
  {
    'name': 'Bitcoin',
    'image': 'assets/img/bitcoin.png',
    'description': '믿는자에게 복이 있나니',
    'csv': 'assets/csv/btc.csv',
    'color': Colors.orange, // 오렌지 색상 추가
    'startDate': DateTime(2019, 1, 14)
  },
  {
    'name': 'Ethereum',
    'image': 'assets/img/ethereum.png',
    'description': '스마트 컨트랙트 혁명의 시작',
    'csv': 'assets/csv/eth.csv',
    'color': const Color(0xFF687EE3), // 연보라 색상 추가
    'startDate': DateTime(2019, 1, 14)
  },
  {
    'name': 'Solana',
    'image': 'assets/img/solana.png',
    'description': '속도로 승부하는 차세대 블록체인',
    'csv': 'assets/csv/sol.csv',
    'color': const Color(0xFF16C7073), // 연보라 색상 추가
    'startDate': DateTime(2019, 1, 14)
  },
  {
    'name': 'Doge',
    'image': 'assets/img/doge.png',
    'description': '이 코인은 밈인가, 화폐인가?',
    'csv': 'assets/csv/doge.csv',
    'color': const Color(0xFFD9C27E), // 연보라 색상 추가
    'startDate': DateTime(2021, 2, 21)
  },
  {
    'name': 'Tron',
    'image': 'assets/img/trx.png',
    'description': '분산화를 위한 중앙화된 노력',
    'csv': 'assets/csv/trx.csv',
    'color': const Color(0xFFF20544), // 연보라 색상 추가
    'startDate': DateTime(2019, 1, 14)
  },
  {
    'name': 'Ripple',
    'image': 'assets/img/xrp.png',
    'description': '빠르고 효율적인 국제 송금',
    'csv': 'assets/csv/ripple.csv',
    'color': const Color(0xFF16C7073), // 연보라 색상 추가
    'startDate': DateTime(2019, 1, 14)
  },
];
