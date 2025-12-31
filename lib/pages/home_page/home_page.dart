import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';
import 'widgets/timeline_view.dart';
import 'widgets/routine_panel.dart';
import 'widgets/statistics_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Provider에서 데이터 가져오기
    final scheduleProvider = context.watch<ScheduleProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final schedules = scheduleProvider.schedules;
    final categories = categoryProvider.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 왼쪽 2/5: 타임라인 영역
          const Expanded(
            flex: 2,
            child: TimelineView(),
          ),

          // 2. 오른쪽 3/5 영역
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  // 날짜 표시 영역
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrown.withValues(alpha: 0.1),
                      border: Border(
                        left: BorderSide(
                          color: AppColors.primaryBrown.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: AppColors.primaryBrown.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ),

                  // 오른쪽 상단: 루틴 체크리스트
                  const Expanded(
                    flex: 1,
                    child: RoutinePanel(),
                  ),

                  // 오른쪽 하단: 카테고리별 시간 통계
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border(
                          top: BorderSide(
                            color: AppColors.primaryBrown.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          left: BorderSide(
                            color: AppColors.primaryBrown.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: StatisticsPanel(
                        schedules: schedules,
                        categories: categories,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜를 "YYYY년 M월 d일 (요일)" 형식으로 포맷
  String _formatDate(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
  }
}
