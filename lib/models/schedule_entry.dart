import 'package:flutter/material.dart';
import 'activity_category.dart';

/// 타임라인에 표시될 일정 항목
class ScheduleEntry {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ActivityCategory category;
  final int track; // 0: 왼쪽 트랙, 1: 오른쪽 트랙

  ScheduleEntry({
    required this.startTime,
    required this.endTime,
    required this.category,
    this.track = 0, // 기본값: 왼쪽 트랙
  });
}
