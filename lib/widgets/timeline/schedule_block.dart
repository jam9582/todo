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
  final VoidCallback? onTap;

  const ScheduleBlock({
    super.key,
    required this.entry,
    this.isPreview = false,
    required this.isEditMode,
    required this.hourHeight,
    required this.timelineWidth,
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

    return Positioned(
      top: top,
      left: timelineWidth + 4.0,
      right: 4.0,
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
