import 'package:flutter/material.dart';
import '../../models/schedule_entry.dart';
import '../../utils/constants.dart';

/// 일정 블록 위젯
class ScheduleBlock extends StatelessWidget {
  final ScheduleEntry entry;
  final bool isPreview;
  final bool isEditMode;
  final double hourHeight;
  final double timelineWidth;
  final double totalWidth; // 타임라인 전체 너비
  final VoidCallback? onTap;

  const ScheduleBlock({
    super.key,
    required this.entry,
    this.isPreview = false,
    required this.isEditMode,
    required this.hourHeight,
    required this.timelineWidth,
    required this.totalWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double minuteHeight = hourHeight / 60.0;

    final double startMinutes = entry.startTime.hour * 60.0 + entry.startTime.minute;
    double endMinutes = entry.endTime.hour * 60.0 + entry.endTime.minute;
    if (entry.endTime.hour == 0 && entry.endTime.minute == 0) {
      endMinutes = 24 * 60.0;
    }

    final double top = startMinutes * minuteHeight;
    final double height = (endMinutes - startMinutes) * minuteHeight;

    if (height <= 0) return const SizedBox.shrink();

    // 트랙별 위치 계산 (화면 너비에서 시간표를 뺀 영역을 2등분)
    // track 0: 왼쪽 트랙, track 1: 오른쪽 트랙
    final double availableWidth = totalWidth - timelineWidth;
    final double trackWidth = availableWidth / 2;
    final int trackNumber = entry.track; // null-safe

    // 각 트랙 내에서 중앙 정렬 (좌우 여백 추가)
    final double horizontalPadding = 8.0;
    final double blockWidth = trackWidth - (horizontalPadding * 2);
    final double trackLeft = trackNumber == 0
        ? timelineWidth + horizontalPadding
        : timelineWidth + trackWidth + horizontalPadding;

    return Positioned(
      top: top,
      left: trackLeft,
      width: blockWidth,
      height: height,
      child: GestureDetector(
        onTap: isEditMode && !isPreview ? onTap : null,
        child: Opacity(
          opacity: isPreview ? 0.6 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: entry.category.color.withValues(alpha: isPreview ? 0.5 : 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: entry.category.color,
                width: isEditMode && !isPreview ? 2.5 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.category.name,
                    style: const TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isEditMode && !isPreview)
                  const Icon(
                    Icons.delete_outline,
                    color: AppColors.background,
                    size: AppSizes.deleteIconSize,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
