import 'package:flutter/material.dart';
import 'activity_category.dart';

/// 타임라인에 표시될 일정 항목
class ScheduleEntry {
  final DateTime date; // 일정 날짜
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ActivityCategory category;
  final int track; // 0: 왼쪽 트랙, 1: 오른쪽 트랙

  ScheduleEntry({
    DateTime? date, // nullable로 받아서 기본값 처리
    required this.startTime,
    required this.endTime,
    required this.category,
    this.track = 0, // 기본값: 왼쪽 트랙
  }) : date = date ?? DateTime.now(); // 기본값: 오늘

  /// 날짜가 같은지 비교 (시간 제외)
  bool isSameDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}
