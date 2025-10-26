import 'package:flutter/material.dart';
import 'activity_category.dart';

/// 타임라인에 표시될 일정 항목
class ScheduleEntry {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ActivityCategory category;

  ScheduleEntry({
    required this.startTime,
    required this.endTime,
    required this.category,
  });
}
