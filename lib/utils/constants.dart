import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 상수
class AppColors {
  // 배경색
  static const Color background = Color(0xFFFAF8F3); // 연한 아이보리

  // 브라운 계열
  static const Color primaryBrown = Color(0xFF8B6B47);
  static const Color darkBrown = Color(0xFF6B4E3D);
  static const Color lightBrown = Color(0xFFD4A574);
  static const Color veryLightBrown = Color(0xFFB4926F);

  // 카테고리 색상
  static const Color categoryWork = Color(0xFF8B6B47);
  static const Color categoryStudy = Color(0xFFB4926F);
  static const Color categoryMeal = Color(0xFFD4A574);
  static const Color categoryExercise = Color(0xFFA67B5B);
  static const Color categoryRest = Color(0xFFC9A88A);
  static const Color categoryGame = Color(0xFF9E7E5E);
}

/// 앱 전체에서 사용하는 크기 상수
class AppSizes {
  // 타임라인
  static const double hourHeight = 50.0;
  static const double timelineWidth = 40.0;

  // 아이콘
  static const double menuIconSize = 28.0;
  static const double fabIconSize = 24.0;
  static const double deleteIconSize = 16.0;
  static const double categoryIconSize = 22.0;
}
