import 'package:flutter/material.dart';
import '../models/activity_category.dart';
import '../utils/constants.dart';

/// 카테고리 전역 상태 관리
class CategoryProvider extends ChangeNotifier {
  // 기본 카테고리 목록
  final List<ActivityCategory> _categories = [
    ActivityCategory(name: '업무', icon: Icons.work, color: AppColors.categoryWork),
    ActivityCategory(name: '공부', icon: Icons.book, color: AppColors.categoryStudy),
    ActivityCategory(name: '식사', icon: Icons.restaurant, color: AppColors.categoryMeal),
    ActivityCategory(name: '운동', icon: Icons.fitness_center, color: AppColors.categoryExercise),
    ActivityCategory(name: '휴식', icon: Icons.self_improvement, color: AppColors.categoryRest),
    ActivityCategory(name: '게임', icon: Icons.gamepad, color: AppColors.categoryGame),
  ];

  /// 카테고리 목록 가져오기 (읽기 전용)
  List<ActivityCategory> get categories => List.unmodifiable(_categories);

  /// 카테고리 추가 (나중에 사용자 정의 카테고리 기능 추가 시)
  void addCategory(ActivityCategory category) {
    _categories.add(category);
    notifyListeners(); // 모든 리스너에게 변경 알림
  }

  /// 카테고리 삭제
  void removeCategory(String categoryName) {
    _categories.removeWhere((cat) => cat.name == categoryName);
    notifyListeners();
  }

  /// 이름으로 카테고리 찾기
  ActivityCategory? findCategoryByName(String name) {
    try {
      return _categories.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }
}
