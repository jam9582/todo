import 'package:flutter/material.dart';
import '../../../models/activity_category.dart';
import '../../../models/schedule_entry.dart';
import '../../../utils/constants.dart';
import '../../../utils/time_utils.dart';

/// 카테고리별 시간 통계 패널
class StatisticsPanel extends StatelessWidget {
  final List<ScheduleEntry> schedules;
  final List<ActivityCategory> categories;

  const StatisticsPanel({
    super.key,
    required this.schedules,
    required this.categories,
  });

  /// 카테고리별 총 시간(분) 계산
  Map<String, int> _calculateCategoryTimes() {
    final Map<String, int> categoryTimes = {};

    for (final schedule in schedules) {
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

  @override
  Widget build(BuildContext context) {
    final categoryTimes = _calculateCategoryTimes();

    if (categoryTimes.isEmpty) {
      return const Center(
        child: Text(
          '일정을 추가하면\n통계가 표시됩니다',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryBrown,
            fontSize: 14,
          ),
        ),
      );
    }

    // 카테고리별 색상 매핑
    final categoryColors = {
      for (var cat in categories) cat.name: cat
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 활동 시간',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: categoryTimes.entries.map((entry) {
              final category = categoryColors[entry.key];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    // 카테고리 아이콘
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: category!.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        category.icon,
                        size: 18,
                        color: category.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 카테고리 이름
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: category.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // 시간
                    Text(
                      TimeUtils.formatMinutes(entry.value),
                      style: TextStyle(
                        color: category.color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(color: AppColors.primaryBrown),
        // 총 시간
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 시간',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              Text(
                TimeUtils.formatMinutes(
                  categoryTimes.values.fold(0, (sum, time) => sum + time),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBrown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
