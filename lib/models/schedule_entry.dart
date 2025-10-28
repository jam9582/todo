import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'activity_category.dart';

part 'schedule_entry.g.dart';

/// 타임라인에 표시될 일정 항목
@HiveType(typeId: 0)
class ScheduleEntry extends HiveObject {
  @HiveField(0)
  DateTime date; // 일정 날짜

  @HiveField(1)
  int startTimeMinutes; // TimeOfDay를 분으로 저장

  @HiveField(2)
  int endTimeMinutes; // TimeOfDay를 분으로 저장

  @HiveField(3)
  ActivityCategory category;

  @HiveField(4)
  int track; // 0: 왼쪽 트랙, 1: 오른쪽 트랙

  // getter로 TimeOfDay 변환
  TimeOfDay get startTime => TimeOfDay(
        hour: startTimeMinutes ~/ 60,
        minute: startTimeMinutes % 60,
      );

  TimeOfDay get endTime => TimeOfDay(
        hour: endTimeMinutes ~/ 60,
        minute: endTimeMinutes % 60,
      );

  ScheduleEntry({
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? startTimeMinutes,
    int? endTimeMinutes,
    required this.category,
    this.track = 0,
  })  : date = date ?? DateTime.now(),
        startTimeMinutes = startTimeMinutes ?? (startTime!.hour * 60 + startTime.minute),
        endTimeMinutes = endTimeMinutes ?? (endTime!.hour * 60 + endTime.minute);

  /// 날짜가 같은지 비교 (시간 제외)
  bool isSameDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}
