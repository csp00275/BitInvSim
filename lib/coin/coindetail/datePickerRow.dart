// lib/widgets/date_picker_row.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 날짜 선택 행 위젯
class DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? minimumDate;
  final Color mainColor;

  const DatePickerRow({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.minimumDate,
    required this.mainColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// 선택된 날짜 텍스트
        Expanded(
          flex: 7,
          child: Text(
            selectedDate == null
                ? "선택 안됨"
                : DateFormat('yyyy-MM').format(selectedDate!),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ),

        /// 캘린더 버튼
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (_) {
                  final DateTime now = DateTime.now();
                  final DateTime safeMinDate =
                      minimumDate ?? DateTime(2000, 1, 1);
                  final DateTime initDate = selectedDate ??
                      (safeMinDate.isBefore(now) ? safeMinDate : now);

                  return Container(
                    height: 250,
                    color: Colors.white,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initDate,
                      minimumDate: safeMinDate,
                      maximumDate: now,
                      onDateTimeChanged: (DateTime date) {
                        onDateSelected(date);
                      },
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.calendar_today,
              color: mainColor,
            ),
            label: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: mainColor,
              /*shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // 원하는 둥글기
                side: BorderSide(
                  color: mainColor, // 테두리 색상
                  width: 2, // 테두리 두께
                ),
              ),*/
            ),
          ),
        ),
      ],
    );
  }
}
