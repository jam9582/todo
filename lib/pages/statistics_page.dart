import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/time_utils.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    // Provider에서 데이터 가져오기
    final scheduleProvider = context.watch<ScheduleProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final categoryTimes = scheduleProvider.getCategoryTimes();
    final totalMinutes = scheduleProvider.getTotalMinutes();
    final categories = categoryProvider.categories;

    // 카테고리별 색상 매핑
    final categoryColors = {
      for (var cat in categories) cat.name: cat
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '통계',
          style: TextStyle(
            color: AppColors.darkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: categoryTimes.isEmpty
          ? const Center(
              child: Text(
                '일정을 추가하면\n누적 통계가 표시됩니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryBrown,
                  fontSize: 16,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 총 시간 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrown,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '전체 활동 시간',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          TimeUtils.formatMinutes(totalMinutes),
                          style: const TextStyle(
                            color: AppColors.background,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 카테고리별 통계
                  const Text(
                    '카테고리별 시간',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 카테고리 목록
                  ...categoryTimes.entries.map((entry) {
                    final category = categoryColors[entry.key];
                    final percentage = totalMinutes > 0
                        ? (entry.value / totalMinutes * 100).toStringAsFixed(1)
                        : '0.0';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: category!.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: category.color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 아이콘
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              category.icon,
                              size: 24,
                              color: category.color,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 카테고리 이름 & 퍼센트
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    color: category.color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    color: category.color.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 시간
                          Text(
                            TimeUtils.formatMinutes(entry.value),
                            style: TextStyle(
                              color: category.color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
