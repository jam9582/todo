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
  final bool isResizing; // 시간 조정 중인지 여부
  final VoidCallback? onTap;
  final Function(LongPressStartDetails)? onLongPressStart; // 길게 누르기 시작
  final Function(LongPressMoveUpdateDetails)? onLongPressMoveUpdate; // 길게 누르고 드래그 중
  final Function(LongPressEndDetails)? onLongPressEnd; // 길게 누르기 종료

  const ScheduleBlock({
    super.key,
    required this.entry,
    this.isPreview = false,
    required this.isEditMode,
    required this.hourHeight,
    required this.timelineWidth,
    required this.totalWidth,
    this.isResizing = false,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
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

    // 시간 조정 중이면 트랙 전체 너비, 아니면 중앙 정렬
    final double horizontalPadding = isResizing ? 0.0 : 8.0;
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
        onTap: isEditMode && !isPreview && !isResizing ? onTap : null,
        onLongPressStart: isEditMode && !isPreview ? onLongPressStart : null,
        onLongPressMoveUpdate: isEditMode && !isPreview ? onLongPressMoveUpdate : null,
        onLongPressEnd: isEditMode && !isPreview ? onLongPressEnd : null,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    entry.category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isEditMode && !isPreview && !isResizing)
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
