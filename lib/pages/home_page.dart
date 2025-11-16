import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity_category.dart';
import '../models/schedule_entry.dart';
import '../providers/schedule_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/timeline/timeline_painter.dart';
import '../widgets/timeline/schedule_block.dart';
import '../widgets/routine/routine_check_item.dart';
import '../widgets/statistics/statistics_panel.dart';
import '../utils/constants.dart';
import '../utils/time_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- 상태 변수 ---
  // _schedules와 _categories는 Provider에서 관리

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

  /// 시간 조정 중인 일정의 인덱스 (-1이면 조정 중 아님)
  int _resizingIndex = -1;

  /// 길게 누르기 시작한 Y 좌표 (타임라인 기준)
  double _longPressStartY = 0.0;

  /// 조정 중인 시간선 ('start' 또는 'end')
  String _resizingEdge = '';

  /// 타임라인 스택의 GlobalKey (좌표 변환용)
  final GlobalKey _timelineStackKey = GlobalKey();

  // --- 빌드 메서드 ---

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
          // 1. 왼쪽 2/5: 스크롤 가능한 타임라인 & 블록 영역
          Expanded(
            flex: 2, // 2/5 비율
            child: LayoutBuilder(
              builder: (context, constraints) {
                final leftWidth = constraints.maxWidth;

                return Container(
                  color: AppColors.background,
                  child: Stack(
                    children: [
                    // 스크롤 가능한 타임라인
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20), // 00시 텍스트가 잘리지 않도록
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
                            ...schedules.asMap().entries.map((mapEntry) {
                              final index = mapEntry.key;
                              final entry = mapEntry.value;
                              return ScheduleBlock(
                                entry: entry,
                                isEditMode: _isEditMode,
                                hourHeight: AppSizes.hourHeight,
                                timelineWidth: AppSizes.timelineWidth,
                                totalWidth: leftWidth,
                                isResizing: _resizingIndex == index,
                                onTap: () => _deleteSchedule(entry),
                                onLongPressStart: (details) => _onBlockLongPressStart(index, details),
                                onLongPressMoveUpdate: (details) => _onBlockLongPressMoveUpdate(details),
                                onLongPressEnd: (details) => _onBlockLongPressEnd(),
                              );
                            }),

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
                      ), // Padding 닫기
                    ), // SingleChildScrollView 닫기
                    // + 버튼 (플로팅)
                    Positioned(
                      bottom: 16,
                      left: 16,
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
              );
            },
          ),
          ),
          // 2. 오른쪽 3/5 영역
          Expanded(
            flex: 3, // 3/5 비율
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

  // --- 헬퍼 메서드 ---

  /// 날짜를 "YYYY년 M월 d일 (요일)" 형식으로 포맷
  String _formatDate(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
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
          if (_resizingIndex == -1) {
            _onDragStart(details, track);
          }
        },
        onVerticalDragUpdate: (details) {
          // 시간 조정 모드가 아닐 때만 일반 드래그
          if (_resizingIndex == -1) {
            _onDragUpdate(details);
          }
        },
        onVerticalDragEnd: (details) {
          // 시간 조정 모드가 아닐 때만 일반 드래그 종료
          if (_resizingIndex == -1) {
            _onDragEnd(details);
          }
        },
        behavior: HitTestBehavior.translucent,
      ),
    );
  }

  // --- 시간 조정 관련 메서드 ---

  /// 블록을 길게 누르기 시작
  void _onBlockLongPressStart(int index, LongPressStartDetails details) {
    // 타임라인 Stack의 RenderBox를 가져와서 좌표 변환
    final RenderBox? stackRenderBox = _timelineStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackRenderBox == null) return;

    // globalPosition을 타임라인 Stack 기준의 localPosition으로 변환
    final localPos = stackRenderBox.globalToLocal(details.globalPosition);

    // 현재 일정의 시작/끝 Y 위치 계산
    final schedules = context.read<ScheduleProvider>().schedules;
    final currentEntry = schedules[index];
    final double minuteHeight = AppSizes.hourHeight / 60.0;
    final double startMinutes = currentEntry.startTime.hour * 60.0 + currentEntry.startTime.minute;
    double endMinutes = currentEntry.endTime.hour * 60.0 + currentEntry.endTime.minute;
    if (currentEntry.endTime.hour == 0 && currentEntry.endTime.minute == 0) {
      endMinutes = 24 * 60.0;
    }

    final double startY = startMinutes * minuteHeight;
    final double endY = endMinutes * minuteHeight;
    final double centerY = (startY + endY) / 2;

    // 누른 위치가 블록의 위쪽 절반이면 시작 시간선, 아래쪽 절반이면 끝 시간선
    final String edge = localPos.dy < centerY ? 'start' : 'end';

    setState(() {
      _resizingIndex = index;
      _longPressStartY = localPos.dy;
      _resizingEdge = edge;
    });
  }

  /// 블록을 길게 누르고 드래그 중
  void _onBlockLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_resizingIndex == -1) return;

    final scheduleProvider = context.read<ScheduleProvider>();
    final schedules = scheduleProvider.schedules;

    if (_resizingIndex < 0 || _resizingIndex >= schedules.length) return;

    // 타임라인 Stack의 RenderBox를 가져와서 좌표 변환
    final RenderBox? stackRenderBox = _timelineStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackRenderBox == null) return;

    // globalPosition을 타임라인 Stack 기준의 localPosition으로 변환
    final localPos = stackRenderBox.globalToLocal(details.globalPosition);
    final currentY = localPos.dy;

    final currentEntry = schedules[_resizingIndex];

    // _resizingEdge에 따라 어느 시간선을 조정할지 결정
    int startMinutes, endMinutes;

    if (_resizingEdge == 'start') {
      // 시작 시간선을 조정, 끝 시간 고정
      final draggedTime = TimeUtils.getTimeFromOffset(currentY, AppSizes.hourHeight);
      startMinutes = draggedTime.hour * 60 + draggedTime.minute;
      endMinutes = currentEntry.endTimeMinutes;

      // 다른 일정에 막히는지 체크 (역방향: endMinutes 이전에 끝나는 일정 찾기)
      startMinutes = scheduleProvider.getMinStartMinutes(
        date: currentEntry.date,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        track: currentEntry.track,
        excludeIndex: _resizingIndex,
      );
    } else {
      // 끝 시간선을 조정, 시작 시간 고정
      startMinutes = currentEntry.startTimeMinutes;
      final draggedTime = TimeUtils.getTimeFromOffset(currentY, AppSizes.hourHeight);
      endMinutes = draggedTime.hour * 60 + draggedTime.minute;
      if (draggedTime.hour == 0 && draggedTime.minute == 0) endMinutes = 24 * 60;

      // 다른 일정에 막히는지 체크
      endMinutes = scheduleProvider.getMaxEndMinutes(
        date: currentEntry.date,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        track: currentEntry.track,
        excludeIndex: _resizingIndex,
      );
    }

    // 최소 30분 검증
    if (endMinutes - startMinutes < 30) return;

    // Provider를 통해 일정 업데이트
    scheduleProvider.updateSchedule(
      _resizingIndex,
      ScheduleEntry(
        date: currentEntry.date,
        startTime: TimeOfDay(hour: startMinutes ~/ 60, minute: startMinutes % 60),
        endTime: TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60),
        track: currentEntry.track,
        category: currentEntry.category,
      ),
    );
  }

  /// 블록 길게 누르기 종료
  void _onBlockLongPressEnd() {
    setState(() {
      _resizingIndex = -1;
      _longPressStartY = 0.0;
      _resizingEdge = '';
    });
  }

  // --- 드래그 관련 메서드 ---

  /// 특정 시간과 트랙에 일정이 있는지 확인
  bool _hasScheduleAt(TimeOfDay time, int track) {
    final timeInMinutes = time.hour * 60 + time.minute;
    final schedules = context.read<ScheduleProvider>().schedules;

    for (final schedule in schedules) {
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

    final scheduleProvider = context.read<ScheduleProvider>();
    final startTimeInMinutes = _dragStartTime!.hour * 60 + _dragStartTime!.minute;
    var endTimeInMinutes = _dragEndTime!.hour * 60 + _dragEndTime!.minute;

    // 00:00은 24:00(1440분)으로 처리
    if (_dragEndTime!.hour == 0 && _dragEndTime!.minute == 0) {
      endTimeInMinutes = 24 * 60;
    }

    // 시작/끝 정렬
    int actualStart, actualEnd;
    if (startTimeInMinutes < endTimeInMinutes) {
      actualStart = startTimeInMinutes;
      actualEnd = endTimeInMinutes;

      // 다른 일정에 막히는지 체크
      actualEnd = scheduleProvider.getMaxEndMinutes(
        date: DateTime.now(),
        startMinutes: actualStart,
        endMinutes: actualEnd,
        track: _selectedTrack,
      );
    } else {
      // 역방향 드래그
      actualStart = endTimeInMinutes;
      actualEnd = startTimeInMinutes;

      // 다른 일정에 막히는지 체크
      actualStart = scheduleProvider.getMinStartMinutes(
        date: DateTime.now(),
        startMinutes: actualStart,
        endMinutes: actualEnd,
        track: _selectedTrack,
      );
    }

    setState(() {
      _previewEntry = ScheduleEntry(
        startTime: TimeOfDay(hour: actualStart ~/ 60, minute: actualStart % 60),
        endTime: TimeOfDay(hour: actualEnd ~/ 60, minute: actualEnd % 60),
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
                context.read<ScheduleProvider>().removeSchedule(entry);
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
    final categories = context.read<CategoryProvider>().categories;

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
                children: categories.map((category) {
                  return InkWell(
                    onTap: () {
                      context.read<ScheduleProvider>().addSchedule(ScheduleEntry(
                        startTime: _previewEntry!.startTime,
                        endTime: _previewEntry!.endTime,
                        track: _previewEntry!.track,
                        category: category,
                      ));
                      setState(() {
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
