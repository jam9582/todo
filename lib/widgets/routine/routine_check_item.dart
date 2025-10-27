import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// 루틴 체크 아이템 위젯
class RoutineCheckItem extends StatelessWidget {
  final Map<String, dynamic> routine;
  final bool isEditMode;
  final VoidCallback onCheckToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoutineCheckItem({
    super.key,
    required this.routine,
    required this.isEditMode,
    required this.onCheckToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCheckToggle,
            child: Icon(
              routine['checked'] ? Icons.check_box : Icons.check_box_outline_blank,
              color: AppColors.primaryBrown,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: isEditMode ? onEdit : null,
              child: Text(
                routine['text'],
                style: TextStyle(
                  color: AppColors.darkBrown,
                  fontSize: 14,
                  decoration: routine['checked'] ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 편집 모드일 때 삭제 버튼 표시
          if (isEditMode)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.remove_circle_outline,
                color: AppColors.lightBrown,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
