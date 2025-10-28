import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'activity_category.g.dart';

/// 사용자가 선택할 활동 카테고리 (아이콘, 색상, 이름)
@HiveType(typeId: 1)
class ActivityCategory extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int iconCodePoint; // IconData는 직접 저장 안 되니까 codePoint만

  @HiveField(2)
  int colorValue; // Color도 int로 저장

  // 실제 사용할 getter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  ActivityCategory({
    required this.name,
    IconData? icon,
    Color? color,
    int? iconCodePoint,
    int? colorValue,
  })  : iconCodePoint = iconCodePoint ?? icon!.codePoint,
        colorValue = colorValue ?? color!.value;
}
