import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';

/// 일정 전역 상태 관리
class ScheduleProvider extends ChangeNotifier {
  // 저장된 모든 일정
  final List<ScheduleEntry> _schedules = [];

  /// 일정 목록 가져오기 (읽기 전용)
  List<ScheduleEntry> get schedules => List.unmodifiable(_schedules);

  /// 일정 추가
  void addSchedule(ScheduleEntry entry) {
    _schedules.add(entry);
    notifyListeners(); // 모든 리스너에게 변경 알림
  }

  /// 일정 삭제
  void removeSchedule(ScheduleEntry entry) {
    _schedules.remove(entry);
    notifyListeners();
  }

  /// 일정 수정 (인덱스로)
  void updateSchedule(int index, ScheduleEntry newEntry) {
    if (index >= 0 && index < _schedules.length) {
      _schedules[index] = newEntry;
      notifyListeners();
    }
  }

  /// 모든 일정 삭제
  void clearSchedules() {
    _schedules.clear();
    notifyListeners();
  }

  /// 특정 날짜의 일정만 가져오기 (나중에 캘린더에서 사용)
  List<ScheduleEntry> getSchedulesForDate(DateTime date) {
    // TODO: 날짜별 필터링 구현 (현재는 모든 일정이 "오늘" 것으로 간주)
    return List.unmodifiable(_schedules);
  }

  /// 카테고리별 총 시간(분) 계산
  Map<String, int> getCategoryTimes() {
    final Map<String, int> categoryTimes = {};

    for (final schedule in _schedules) {
      final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
      var endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;
      if (schedule.endTime.hour == 0 && schedule.endTime.minute == 0) {
        endMinutes = 24 * 60;
      }

      final duration = endMinutes - startMinutes;
      final categoryName = schedule.category.name;

      categoryTimes[categoryName] = (categoryTimes[categoryName] ?? 0) + duration;
    }

    return categoryTimes;
  }

  /// 총 시간(분) 계산
  int getTotalMinutes() {
    return getCategoryTimes().values.fold(0, (sum, time) => sum + time);
  }
}
