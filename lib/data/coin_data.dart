// lib/data/coin_data.dart

import 'package:flutter/material.dart';

final List<Map<String, dynamic>> coinData = [
  {
    'name': 'Bitcoin',
    'image': 'assets/img/bitcoin.png',
    'description': '믿는자에게 복이 있나니',
    'csv': 'assets/csv/btc.csv',
    'color': Colors.orange, // 오렌지 색상 추가
  },
  {
    'name': 'Ethereum',
    'image': 'assets/img/ethereum.png',
    'description': '의심하고 또 의심하라',
    'csv': 'assets/csv/eth.csv',
    'color': Color(0xFF687EE3), // 연보라 색상 추가
  },
  {
    'name': 'Doge',
    'image': 'assets/img/doge.png',
    'description': '일론머스크',
    'csv': 'assets/csv/doge.csv',
    'color': Color(0xFFD9C27E), // 연보라 색상 추가
  },

  {
    'name': 'Tron',
    'image': 'assets/img/trx.png',
    'description': '전송용 코인',
    'csv': 'assets/csv/trx.csv',
    'color': Color(0xFFF20544), // 연보라 색상 추가
  },

  {
    'name': 'Ripple',
    'image': 'assets/img/xrp.png',
    'description': '리플 지폐 간다',
    'csv': 'assets/csv/ripple.csv',
    'color': Color(0xFF16C7073), // 연보라 색상 추가
  },


  /*
  {
    'name': 'Solana',
    'image': 'assets/img/solana.png',
    'description': '솔라나의 간단 설명',
    'csv': 'assets/csv/sol.csv',
    'gradient': Colors.black,
  },*/
];
