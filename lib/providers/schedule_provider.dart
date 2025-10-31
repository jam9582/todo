import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';
import '../services/storage_service.dart';

/// 일정 전역 상태 관리
class ScheduleProvider extends ChangeNotifier {
  // 저장된 모든 일정
  List<ScheduleEntry> _schedules = [];

  /// 생성자: Hive에서 데이터 로드
  ScheduleProvider() {
    _loadFromHive();
  }

  /// Hive에서 일정 로드
  void _loadFromHive() {
    _schedules = StorageService.loadSchedules();
    notifyListeners();
  }

  /// 일정 목록 가져오기 (읽기 전용)
  List<ScheduleEntry> get schedules => List.unmodifiable(_schedules);

  /// 일정 추가
  Future<void> addSchedule(ScheduleEntry entry) async {
    _schedules.add(entry);
    await StorageService.saveSchedule(entry); // Hive에 저장
    notifyListeners(); // 모든 리스너에게 변경 알림
  }

  /// 일정 삭제
  Future<void> removeSchedule(ScheduleEntry entry) async {
    _schedules.remove(entry);
    await StorageService.deleteSchedule(entry); // Hive에서 삭제
    notifyListeners();
  }

  /// 일정 수정 (인덱스로)
  Future<void> updateSchedule(int index, ScheduleEntry newEntry) async {
    if (index >= 0 && index < _schedules.length) {
      final oldEntry = _schedules[index];

      // 기존 entry의 Hive key를 유지하면서 데이터 업데이트
      oldEntry.date = newEntry.date;
      oldEntry.startTimeMinutes = newEntry.startTimeMinutes;
      oldEntry.endTimeMinutes = newEntry.endTimeMinutes;
      oldEntry.category = newEntry.category;
      oldEntry.track = newEntry.track;

      await StorageService.updateSchedule(oldEntry); // Hive 업데이트
      notifyListeners();
    }
  }

  /// 모든 일정 삭제
  Future<void> clearSchedules() async {
    _schedules.clear();
    await StorageService.clearAllSchedules(); // Hive 클리어
    notifyListeners();
  }

  /// 특정 날짜의 일정만 가져오기
  List<ScheduleEntry> getSchedulesForDate(DateTime date) {
    return List.unmodifiable(
      _schedules.where((schedule) => schedule.isSameDate(date)).toList(),
    );
  }

  /// 특정 날짜의 주요 카테고리 정보 가져오기 (캘린더 마커용)
  /// 반환: {category: CategoryInfo, totalMinutes: int}
  Map<String, dynamic>? getMainCategoryForDate(DateTime date) {
    final daySchedules = getSchedulesForDate(date);
    if (daySchedules.isEmpty) return null;

    // 해당 날짜의 카테고리별 시간 계산
    final Map<String, int> categoryTimes = {};
    final Map<String, dynamic> categoryInfo = {};

    for (final schedule in daySchedules) {
      final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
      var endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;
      if (schedule.endTime.hour == 0 && schedule.endTime.minute == 0) {
        endMinutes = 24 * 60;
      }

      final duration = endMinutes - startMinutes;
      final categoryName = schedule.category.name;

      categoryTimes[categoryName] = (categoryTimes[categoryName] ?? 0) + duration;
      categoryInfo[categoryName] = schedule.category;
    }

    // 가장 많은 시간을 차지한 카테고리 찾기
    if (categoryTimes.isEmpty) return null;

    final mainCategoryName = categoryTimes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'category': categoryInfo[mainCategoryName],
      'totalMinutes': categoryTimes[mainCategoryName],
    };
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

  /// 드래그 시 가능한 최대 종료 시간 찾기
  /// 같은 날짜, 같은 트랙에서 startMinutes 이후에 시작하는 가장 가까운 일정의 시작 시간을 반환
  /// 반환값: 다른 일정에 막히면 그 일정의 시작 시간, 막히지 않으면 원래 endMinutes
  int getMaxEndMinutes({
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required int track,
    int? excludeIndex,
  }) {
    int maxEnd = endMinutes;

    // 같은 날짜, 같은 트랙의 일정들 순회
    for (int i = 0; i < _schedules.length; i++) {
      // 수정 중인 일정은 제외
      if (excludeIndex != null && i == excludeIndex) continue;

      final schedule = _schedules[i];

      // 같은 날짜, 같은 트랙이 아니면 스킵
      if (!schedule.isSameDate(date) || schedule.track != track) continue;

      final existingStart = schedule.startTimeMinutes;

      // startMinutes 이후에 시작하는 일정 중 가장 가까운 것
      if (existingStart > startMinutes && existingStart < maxEnd) {
        maxEnd = existingStart;
      }
    }

    return maxEnd;
  }

  /// 드래그 시 가능한 최소 시작 시간 찾기 (역방향 드래그용)
  /// 같은 날짜, 같은 트랙에서 endMinutes 이전에 끝나는 가장 가까운 일정의 종료 시간을 반환
  int getMinStartMinutes({
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required int track,
    int? excludeIndex,
  }) {
    int minStart = startMinutes;

    // 같은 날짜, 같은 트랙의 일정들 순회
    for (int i = 0; i < _schedules.length; i++) {
      // 수정 중인 일정은 제외
      if (excludeIndex != null && i == excludeIndex) continue;

      final schedule = _schedules[i];

      // 같은 날짜, 같은 트랙이 아니면 스킵
      if (!schedule.isSameDate(date) || schedule.track != track) continue;

      final existingEnd = schedule.endTimeMinutes;

      // endMinutes 이전에 끝나는 일정 중 가장 가까운 것
      if (existingEnd < endMinutes && existingEnd > minStart) {
        minStart = existingEnd;
      }
    }

    return minStart;
  }
}
