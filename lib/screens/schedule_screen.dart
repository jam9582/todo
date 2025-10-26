import 'package:flutter/material.dart';
import '../models/activity_category.dart';
import '../models/schedule_entry.dart';
import '../widgets/timeline/timeline_painter.dart';
import '../widgets/timeline/schedule_block.dart';
import '../widgets/routine/routine_check_item.dart';
import '../widgets/statistics/statistics_panel.dart';
import '../utils/constants.dart';
import '../utils/time_utils.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // --- 상태 변수 ---

  /// 저장된 모든 일정
  final List<ScheduleEntry> _schedules = [];

  /// 기본으로 제공할 카테고리 목록 (따뜻한 톤으로 변경)
  final List<ActivityCategory> _categories = [
    ActivityCategory(name: '업무', icon: Icons.work, color: AppColors.categoryWork),
    ActivityCategory(name: '공부', icon: Icons.book, color: AppColors.categoryStudy),
    ActivityCategory(name: '식사', icon: Icons.restaurant, color: AppColors.categoryMeal),
    ActivityCategory(name: '운동', icon: Icons.fitness_center, color: AppColors.categoryExercise),
    ActivityCategory(name: '휴식', icon: Icons.self_improvement, color: AppColors.categoryRest),
    ActivityCategory(name: '게임', icon: Icons.gamepad, color: AppColors.categoryGame),
  ];

  /// 루틴 체크리스트
  final List<Map<String, dynamic>> _routines = [
    {'text': '기상 후 씻기', 'checked': false},
    {'text': '자기 전 씻기', 'checked': false},
    {'text': '흑곰이 산책', 'checked': false},
    {'text': '배달 x', 'checked': false},
  ];

  /// 드래그 시작 시간
  TimeOfDay? _dragStartTime;
  /// 드래그 종료 시간
  TimeOfDay? _dragEndTime;

  /// 드래그 중에 사용자에게 보여줄 임시 블록
  ScheduleEntry? _previewEntry;

  /// 편집 모드 상태 (true일 때만 드래그로 일정 추가 가능)
  bool _isEditMode = false;

  /// 드래그한 트랙 (0: 왼쪽, 1: 오른쪽)
  int _selectedTrack = 0;

  /// 시간 조정 중인 일정 (null이면 조정 중 아님)
  ScheduleEntry? _resizingEntry;

  /// 시간 조정 모드 ('start' 또는 'end')
  String? _resizeMode;

  /// 타임라인 스택의 GlobalKey (좌표 변환용)
  final GlobalKey _timelineStackKey = GlobalKey();

  // --- 빌드 메서드 ---

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final leftWidth = screenWidth * 2 / 5; // 왼쪽 2/5
    final rightWidth = screenWidth * 3 / 5; // 오른쪽 3/5

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primaryBrown, size: AppSizes.menuIconSize),
          onPressed: () {
            // 메뉴 기능은 나중에 구현
          },
        ),
      ),
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 왼쪽 1/3: 스크롤 가능한 타임라인 & 블록 영역
          Container(
            width: leftWidth,
            color: AppColors.background,
            child: Stack(
              children: [
                // 스크롤 가능한 타임라인
                SingleChildScrollView(
                  child: SizedBox(
                    // 24시간 * 시간당 높이 = 총 스크롤 높이
                    height: 24 * AppSizes.hourHeight,
                    child: Stack(
                      key: _timelineStackKey,
                      children: [
                        // 1. 배경 (시간, 점선) -> CustomPaint
                        CustomPaint(
                          size: Size(leftWidth, 24 * AppSizes.hourHeight),
                          painter: TimelinePainter(
                            hourHeight: AppSizes.hourHeight,
                            timelineWidth: AppSizes.timelineWidth,
                            totalWidth: leftWidth,
                            context: context,
                          ),
                        ),

                        // 2. 저장된 일정 블록들
                        ..._schedules.map((entry) => ScheduleBlock(
                              entry: entry,
                              isEditMode: _isEditMode,
                              hourHeight: AppSizes.hourHeight,
                              timelineWidth: AppSizes.timelineWidth,
                              totalWidth: leftWidth,
                              isResizing: _resizingEntry == entry,
                              onTap: () => _deleteSchedule(entry),
                              onResizeStartDrag: (details) => _onResizeStart(entry, 'start', details),
                              onResizeStartUpdate: (details) => _onResizeUpdate(details),
                              onResizeStartEnd: (details) => _onResizeEnd(),
                              onResizeEndDrag: (details) => _onResizeStart(entry, 'end', details),
                              onResizeEndUpdate: (details) => _onResizeUpdate(details),
                              onResizeEndEnd: (details) => _onResizeEnd(),
                            )),

                        // 3. 드래그 중인 임시 블록
                        if (_previewEntry != null)
                          ScheduleBlock(
                            entry: _previewEntry!,
                            isPreview: true,
                            isEditMode: _isEditMode,
                            hourHeight: AppSizes.hourHeight,
                            timelineWidth: AppSizes.timelineWidth,
                            totalWidth: leftWidth,
                          ),

                        // 4. 드래그를 감지할 제스처 영역 (편집 모드일 때만)
                        // 트랙 0 (왼쪽)
                        if (_isEditMode) _buildTrackGestureDetector(0, leftWidth),
                        // 트랙 1 (오른쪽)
                        if (_isEditMode) _buildTrackGestureDetector(1, leftWidth),
                      ],
                    ),
                  ),
                ),
                // + 버튼 (플로팅)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _isEditMode = !_isEditMode;
                      });
                    },
                    backgroundColor: _isEditMode ? AppColors.lightBrown : AppColors.primaryBrown,
                    child: Icon(
                      _isEditMode ? Icons.check : Icons.add,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 2. 오른쪽 2/3 영역
          Container(
            width: rightWidth,
            height: screenHeight,
            color: AppColors.background,
            child: Column(
              children: [
                // 오른쪽 상단: 루틴 체크리스트
                Expanded(
                  flex: 1,
                  child: Container(
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
                            // 편집 모드일 때 루틴 추가 버튼 표시
                            if (_isEditMode)
                              GestureDetector(
                                onTap: _addRoutine,
                                child: const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.primaryBrown,
                                  size: 24,
                                ),
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
                  ),
                ),
                // 오른쪽 하단: 카테고리별 시간 통계 (항상 표시)
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
                      schedules: _schedules,
                      categories: _categories,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 위젯 빌더 ---

  /// 트랙별 드래그를 감지하는 투명한 위젯
  Widget _buildTrackGestureDetector(int track, double totalWidth) {
    final double availableWidth = totalWidth - AppSizes.timelineWidth;
    final double trackWidth = availableWidth / 2;

    // 트랙별 위치 계산
    final double trackLeft = track == 0
        ? AppSizes.timelineWidth
        : AppSizes.timelineWidth + trackWidth;

    return Positioned(
      top: 0,
      bottom: 0,
      left: trackLeft,
      width: trackWidth,
      child: GestureDetector(
        onVerticalDragStart: (details) {
          // 시간 조정 모드가 아닐 때만 새 일정 추가 가능
          if (_resizingEntry == null) {
            _onDragStart(details, track);
          }
        },
        onVerticalDragUpdate: (details) {
          // 시간 조정 모드가 아닐 때만 일반 드래그
          if (_resizingEntry == null) {
            _onDragUpdate(details);
          }
        },
        onVerticalDragEnd: (details) {
          // 시간 조정 모드가 아닐 때만 일반 드래그 종료
          if (_resizingEntry == null) {
            _onDragEnd(details);
          }
        },
        behavior: HitTestBehavior.translucent,
      ),
    );
  }

  // --- 시간 조정 관련 메서드 ---

  /// 일정 시간 조정 드래그 시작
  void _onResizeStart(ScheduleEntry entry, String mode, DragStartDetails details) {
    setState(() {
      _resizingEntry = entry;
      _resizeMode = mode;
    });
  }

  /// 일정 시간 조정 드래그 중
  void _onResizeUpdate(DragUpdateDetails details) {
    if (_resizingEntry == null || _resizeMode == null) return;

    // 타임라인 Stack의 RenderBox를 가져와서 좌표 변환
    final RenderBox? stackRenderBox = _timelineStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackRenderBox == null) return;

    // globalPosition을 타임라인 Stack 기준의 localPosition으로 변환
    final localPos = stackRenderBox.globalToLocal(details.globalPosition);
    final newTime = TimeUtils.getTimeFromOffset(
      localPos.dy,
      AppSizes.hourHeight,
    );

    final index = _schedules.indexOf(_resizingEntry!);
    if (index == -1) return;

    TimeOfDay newStartTime = _resizingEntry!.startTime;
    TimeOfDay newEndTime = _resizingEntry!.endTime;

    if (_resizeMode == 'start') {
      newStartTime = newTime;
      // 시작 시간이 종료 시간보다 늦으면 무시
      final startMinutes = newStartTime.hour * 60 + newStartTime.minute;
      var endMinutes = newEndTime.hour * 60 + newEndTime.minute;
      if (newEndTime.hour == 0 && newEndTime.minute == 0) endMinutes = 24 * 60;
      if (startMinutes >= endMinutes) return;
    } else {
      newEndTime = newTime;
      // 종료 시간이 시작 시간보다 이르면 무시
      final startMinutes = newStartTime.hour * 60 + newStartTime.minute;
      final endMinutes = newEndTime.hour * 60 + newEndTime.minute;
      if (endMinutes <= startMinutes && !(newEndTime.hour == 0 && newEndTime.minute == 0)) return;
    }

    setState(() {
      _schedules[index] = ScheduleEntry(
        startTime: newStartTime,
        endTime: newEndTime,
        track: _resizingEntry!.track,
        category: _resizingEntry!.category,
      );
      _resizingEntry = _schedules[index]; // 업데이트된 entry로 교체
    });
  }

  /// 일정 시간 조정 드래그 종료
  void _onResizeEnd() {
    setState(() {
      _resizingEntry = null;
      _resizeMode = null;
    });
  }

  // --- 드래그 관련 메서드 ---

  /// 특정 시간과 트랙에 일정이 있는지 확인
  bool _hasScheduleAt(TimeOfDay time, int track) {
    final timeInMinutes = time.hour * 60 + time.minute;

    for (final schedule in _schedules) {
      // 같은 트랙인지 확인
      if (schedule.track != track) continue;

      final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
      var endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;
      if (schedule.endTime.hour == 0 && schedule.endTime.minute == 0) {
        endMinutes = 24 * 60;
      }

      // 시간이 겹치는지 확인 (시작시간 이상, 종료시간 미만)
      if (timeInMinutes >= startMinutes && timeInMinutes < endMinutes) {
        return true;
      }
    }

    return false;
  }

  /// 드래그 시작
  void _onDragStart(DragStartDetails details, int track) {
    _dragStartTime = TimeUtils.getTimeFromOffset(details.localPosition.dy, AppSizes.hourHeight);

    // 이미 일정이 있는 시간이면 드래그 무시
    if (_hasScheduleAt(_dragStartTime!, track)) {
      _dragStartTime = null;
      _dragEndTime = null;
      _previewEntry = null;
      return;
    }

    _dragEndTime = _dragStartTime;

    // 트랙은 GestureDetector에서 이미 결정되어 전달됨
    _selectedTrack = track;

    setState(() {
      _previewEntry = ScheduleEntry(
        startTime: _dragStartTime!,
        endTime: _dragEndTime!,
        track: _selectedTrack,
        category: ActivityCategory(
          name: '...',
          icon: Icons.drag_handle,
          color: AppColors.primaryBrown.withValues(alpha: 0.6),
        ),
      );
    });
  }

  /// 드래그 중
  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragStartTime == null) return;

    _dragEndTime = TimeUtils.getTimeFromOffset(details.localPosition.dy, AppSizes.hourHeight);

    final startTimeInMinutes = _dragStartTime!.hour * 60 + _dragStartTime!.minute;
    final endTimeInMinutes = _dragEndTime!.hour * 60 + _dragEndTime!.minute;

    setState(() {
      _previewEntry = ScheduleEntry(
        startTime: startTimeInMinutes < endTimeInMinutes ? _dragStartTime! : _dragEndTime!,
        endTime: startTimeInMinutes < endTimeInMinutes ? _dragEndTime! : _dragStartTime!,
        track: _selectedTrack,
        category: _previewEntry!.category,
      );
    });
  }

  /// 드래그 종료
  void _onDragEnd(DragEndDetails details) {
    if (_dragStartTime == null || _dragEndTime == null || _previewEntry == null) return;

    final startTimeInMinutes = _previewEntry!.startTime.hour * 60 + _previewEntry!.startTime.minute;
    final endTimeInMinutes = _previewEntry!.endTime.hour * 60 + _previewEntry!.endTime.minute;

    if (endTimeInMinutes - startTimeInMinutes < 30) {
      setState(() {
        _previewEntry = null;
      });
      return;
    }

    _showCategoryPicker();
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

  // --- 일정 관련 메서드 ---

  /// 일정 삭제
  void _deleteSchedule(ScheduleEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('일정 삭제', style: TextStyle(color: AppColors.darkBrown)),
          content: Text(
            '${entry.category.name} 일정을 삭제하시겠습니까?',
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
                  _schedules.remove(entry);
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

  /// 카테고리 선택 바텀 시트
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '무엇을 하셨나요?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _categories.map((category) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _schedules.add(ScheduleEntry(
                          startTime: _previewEntry!.startTime,
                          endTime: _previewEntry!.endTime,
                          track: _previewEntry!.track,
                          category: category,
                        ));
                        _previewEntry = null;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: category.color, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, color: category.color, size: AppSizes.categoryIconSize),
                          const SizedBox(width: 8),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: category.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _previewEntry = null;
      });
    });
  }
}
