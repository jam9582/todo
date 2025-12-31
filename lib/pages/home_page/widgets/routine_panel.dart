import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'routine_check_item.dart';

/// 홈 화면 우측 상단의 루틴 체크리스트 패널
class RoutinePanel extends StatefulWidget {
  const RoutinePanel({super.key});

  @override
  State<RoutinePanel> createState() => _RoutinePanelState();
}

class _RoutinePanelState extends State<RoutinePanel> {
  /// 편집 모드 상태
  bool _isEditMode = false;

  /// 루틴 체크리스트
  final List<Map<String, dynamic>> _routines = [
    {'text': '기상 후 씻기', 'checked': false},
    {'text': '자기 전 씻기', 'checked': false},
    {'text': '흑곰이 산책', 'checked': false},
    {'text': '배달 x', 'checked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          left: BorderSide(
            color: AppColors.primaryBrown.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘의 루틴',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              Row(
                children: [
                  // 편집 모드일 때 루틴 추가 버튼
                  if (_isEditMode)
                    GestureDetector(
                      onTap: _addRoutine,
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primaryBrown,
                        size: 24,
                      ),
                    ),
                  if (_isEditMode) const SizedBox(width: 12),
                  // 편집 버튼 (항상 표시)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditMode = !_isEditMode;
                      });
                    },
                    child: Icon(
                      _isEditMode ? Icons.check_circle : Icons.edit,
                      color: AppColors.primaryBrown,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _routines.length,
              itemBuilder: (context, index) {
                return RoutineCheckItem(
                  routine: _routines[index],
                  isEditMode: _isEditMode,
                  onCheckToggle: () {
                    setState(() {
                      _routines[index]['checked'] = !_routines[index]['checked'];
                    });
                  },
                  onEdit: () => _editRoutineText(index),
                  onDelete: () => _deleteRoutine(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 루틴 관련 메서드 ---

  /// 루틴 텍스트 수정 다이얼로그
  void _editRoutineText(int index) {
    final controller = TextEditingController(text: _routines[index]['text']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('루틴 수정', style: TextStyle(color: AppColors.darkBrown)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.darkBrown),
            decoration: InputDecoration(
              hintText: '루틴 내용을 입력하세요',
              hintStyle: TextStyle(color: AppColors.primaryBrown.withValues(alpha: 0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryBrown.withValues(alpha: 0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryBrown),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.primaryBrown)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _routines[index]['text'] = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('저장', style: TextStyle(color: AppColors.primaryBrown, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// 루틴 삭제
  void _deleteRoutine(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('루틴 삭제', style: TextStyle(color: AppColors.darkBrown)),
          content: Text(
            '${_routines[index]['text']} 항목을 삭제하시겠습니까?',
            style: const TextStyle(color: AppColors.darkBrown),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.primaryBrown)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _routines.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: AppColors.lightBrown, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 루틴 추가
  void _addRoutine() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('루틴 추가', style: TextStyle(color: AppColors.darkBrown)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: AppColors.darkBrown),
            decoration: InputDecoration(
              hintText: '새 루틴 내용을 입력하세요',
              hintStyle: TextStyle(color: AppColors.primaryBrown.withValues(alpha: 0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryBrown.withValues(alpha: 0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryBrown),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: AppColors.primaryBrown)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _routines.add({'text': controller.text, 'checked': false});
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('추가', style: TextStyle(color: AppColors.primaryBrown, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
