import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';
import '../models/activity_category.dart';
import '../utils/constants.dart';

/// Hive를 사용한 로컬 저장소 서비스
class StorageService {
  static late Box<ScheduleEntry> _scheduleBox;
  static late Box<ActivityCategory> _categoryBox;

  /// Hive 초기화 및 Box 열기
  static Future<void> init() async {
    // Hive 초기화
    await Hive.initFlutter();

    // Adapter 등록
    Hive.registerAdapter(ScheduleEntryAdapter());
    Hive.registerAdapter(ActivityCategoryAdapter());

    // Box 열기
    _scheduleBox = await Hive.openBox<ScheduleEntry>('schedules');
    _categoryBox = await Hive.openBox<ActivityCategory>('categories');

    // 카테고리가 없으면 기본 카테고리 추가
    if (_categoryBox.isEmpty) {
      await _initDefaultCategories();
    }
  }

  /// 기본 카테고리 초기화
  static Future<void> _initDefaultCategories() async {
    final defaultCategories = [
      ActivityCategory(name: '업무', icon: Icons.work, color: AppColors.categoryWork),
      ActivityCategory(name: '공부', icon: Icons.book, color: AppColors.categoryStudy),
      ActivityCategory(name: '식사', icon: Icons.restaurant, color: AppColors.categoryMeal),
      ActivityCategory(name: '운동', icon: Icons.fitness_center, color: AppColors.categoryExercise),
      ActivityCategory(name: '휴식', icon: Icons.self_improvement, color: AppColors.categoryRest),
      ActivityCategory(name: '게임', icon: Icons.gamepad, color: AppColors.categoryGame),
    ];

    for (var category in defaultCategories) {
      await _categoryBox.add(category);
    }
  }

  // ===== Schedule 관련 메서드 =====

  /// 모든 일정 로드
  static List<ScheduleEntry> loadSchedules() {
    return _scheduleBox.values.toList();
  }

  /// 일정 추가
  static Future<void> saveSchedule(ScheduleEntry entry) async {
    await _scheduleBox.add(entry);
  }

  /// 일정 삭제
  static Future<void> deleteSchedule(ScheduleEntry entry) async {
    await entry.delete(); // HiveObject의 delete 메서드 사용
  }

  /// 일정 업데이트
  static Future<void> updateSchedule(ScheduleEntry entry) async {
    await entry.save(); // HiveObject의 save 메서드 사용
  }

  /// 모든 일정 삭제 (테스트용)
  static Future<void> clearAllSchedules() async {
    await _scheduleBox.clear();
  }

  // ===== Category 관련 메서드 =====

  /// 모든 카테고리 로드
  static List<ActivityCategory> loadCategories() {
    return _categoryBox.values.toList();
  }

  /// 카테고리 추가
  static Future<void> saveCategory(ActivityCategory category) async {
    await _categoryBox.add(category);
  }

  /// 카테고리 삭제
  static Future<void> deleteCategory(ActivityCategory category) async {
    await category.delete();
  }

  /// 모든 카테고리 삭제 (테스트용)
  static Future<void> clearAllCategories() async {
    await _categoryBox.clear();
    await _initDefaultCategories(); // 기본 카테고리 다시 추가
  }
}
