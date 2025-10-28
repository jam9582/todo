import 'package:flutter/material.dart';
import '../models/activity_category.dart';
import '../services/storage_service.dart';

/// 카테고리 전역 상태 관리
class CategoryProvider extends ChangeNotifier {
  // 저장된 모든 카테고리
  List<ActivityCategory> _categories = [];

  /// 생성자: Hive에서 데이터 로드
  CategoryProvider() {
    _loadFromHive();
  }

  /// Hive에서 카테고리 로드
  void _loadFromHive() {
    _categories = StorageService.loadCategories();
    notifyListeners();
  }

  /// 카테고리 목록 가져오기 (읽기 전용)
  List<ActivityCategory> get categories => List.unmodifiable(_categories);

  /// 카테고리 추가 (나중에 사용자 정의 카테고리 기능 추가 시)
  Future<void> addCategory(ActivityCategory category) async {
    _categories.add(category);
    await StorageService.saveCategory(category); // Hive에 저장
    notifyListeners(); // 모든 리스너에게 변경 알림
  }

  /// 카테고리 삭제
  Future<void> removeCategory(ActivityCategory category) async {
    _categories.remove(category);
    await StorageService.deleteCategory(category); // Hive에서 삭제
    notifyListeners();
  }

  /// 모든 카테고리 삭제 (테스트용)
  Future<void> clearCategories() async {
    _categories.clear();
    await StorageService.clearAllCategories(); // Hive 클리어 + 기본 카테고리 재추가
    _loadFromHive(); // 재로드
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
