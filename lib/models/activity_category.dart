import 'package:flutter/material.dart';

/// 사용자가 선택할 활동 카테고리 (아이콘, 색상, 이름)
class ActivityCategory {
  final String name;
  final IconData icon;
  final Color color;

  ActivityCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}
