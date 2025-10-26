import 'package:flutter/material.dart';
import 'dart:math' as math;

// --- 1. 데이터 모델 (이전과 동일) ---

/// 사용자가 선택할 활동 카테고리 (아이콘, 색상, 이름)
class ActivityCategory {
  final String name;
  final IconData icon;
  final Color color;

  ActivityCategory({required this.name, required this.icon, required this.color});
}

/// 타임라인에 표시될 일정 항목
class ScheduleEntry {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ActivityCategory category;

  ScheduleEntry({
    required this.startTime,
    required this.endTime,
    required this.category,
  });
}

// --- 2. 앱의 메인 (화면 규격 적용) ---

void main() {
  runApp(const ProtoApp());
}

class ProtoApp extends StatelessWidget {
  const ProtoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루 일과',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5E6D3), // Cream/beige background
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // '가상 폰'을 보여주기 위한 바깥 배경
        backgroundColor: Colors.grey.shade800,
        body: Center(
          // 그림자와 둥근 모서리가 있는 '가상 폰' 프레임
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            // 1. 요청하신 아이폰 규격 (402 x 874)
            child: SizedBox(
              width: 402,
              height: 874,
              child: const ScheduleScreen(), // 실제 앱 화면
            ),
          ),
        ),
      ),
    );
  }
}

// --- 3. 메인 화면 (레이아웃 대폭 수정) ---

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // --- 상태 변수 ---

  /// 1시간의 높이 (픽셀). 60 -> 50으로 더 줄여서 얇게.
  final double _hourHeight = 50.0;
  /// 2. 시간 표시 영역의 너비. 40으로 고정 (매우 얇게)
  final double _timelineWidth = 40.0;

  /// 저장된 모든 일정
  final List<ScheduleEntry> _schedules = [];

  /// 기본으로 제공할 카테고리 목록 (따뜻한 톤으로 변경)
  final List<ActivityCategory> _categories = [
    ActivityCategory(name: '업무', icon: Icons.work, color: const Color(0xFF8B6B47)),
    ActivityCategory(name: '공부', icon: Icons.book, color: const Color(0xFFB4926F)),
    ActivityCategory(name: '식사', icon: Icons.restaurant, color: const Color(0xFFD4A574)),
    ActivityCategory(name: '운동', icon: Icons.fitness_center, color: const Color(0xFFA67B5B)),
    ActivityCategory(name: '휴식', icon: Icons.self_improvement, color: const Color(0xFFC9A88A)),
    ActivityCategory(name: '게임', icon: Icons.gamepad, color: const Color(0xFF9E7E5E)),
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

  // --- 빌드 메서드 ---

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final leftWidth = screenWidth / 3; // 왼쪽 1/3
    final rightWidth = screenWidth * 2 / 3; // 오른쪽 2/3

    return Scaffold(
      appBar: AppBar(
        title: const Text('하루 일과', style: TextStyle(color: Color(0xFFF5E6D3), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B6B47), // Brown header
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFFF5E6D3)),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5E6D3), // Cream background
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 왼쪽 1/3: 스크롤 가능한 타임라인 & 블록 영역
          Container(
            width: leftWidth,
            color: const Color(0xFFF5E6D3),
            child: SingleChildScrollView(
              child: SizedBox(
                // 24시간 * 시간당 높이 = 총 스크롤 높이
                height: 24 * _hourHeight,
                child: Stack(
                  children: [
                    // 1. 배경 (시간, 점선) -> CustomPaint
                    CustomPaint(
                      size: Size(leftWidth, 24 * _hourHeight),
                      painter: TimelinePainter(
                        hourHeight: _hourHeight,
                        timelineWidth: _timelineWidth,
                        context: context,
                      ),
                    ),

                    // 2. 저장된 일정 블록들
                    ..._schedules.map(_buildScheduleBlock),

                    // 3. 드래그 중인 임시 블록
                    if (_previewEntry != null)
                      _buildScheduleBlock(_previewEntry!, isPreview: true),

                    // 4. 드래그를 감지할 제스처 영역
                    _buildGestureDetector(),
                  ],
                ),
              ),
            ),
          ),
          // 2. 오른쪽 2/3 영역
          Container(
            width: rightWidth,
            height: screenHeight,
            color: const Color(0xFFF5E6D3),
            child: Column(
              children: [
                // 오른쪽 상단: 루틴 체크리스트
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6D3),
                      border: Border(
                        left: BorderSide(color: const Color(0xFF8B6B47).withValues(alpha: 0.3), width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 루틴',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B4E3D),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _routines.length,
                            itemBuilder: (context, index) {
                              return _buildRoutineCheckItem(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 오른쪽 하단: 빈 공간 (나중에 사용)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6D3),
                      border: Border(
                        top: BorderSide(color: const Color(0xFF8B6B47).withValues(alpha: 0.3), width: 1),
                        left: BorderSide(color: const Color(0xFF8B6B47).withValues(alpha: 0.3), width: 1),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '',
                        style: TextStyle(color: Color(0xFF8B6B47)),
                      ),
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

  /// 우측 루틴 체크 아이템 (편집 가능)
  Widget _buildRoutineCheckItem(int index) {
    final routine = _routines[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _routines[index]['checked'] = !routine['checked'];
              });
            },
            child: Icon(
              routine['checked'] ? Icons.check_box : Icons.check_box_outline_blank,
              color: const Color(0xFF8B6B47),
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _editRoutineText(index),
              child: Text(
                routine['text'],
                style: TextStyle(
                  color: const Color(0xFF6B4E3D),
                  fontSize: 14,
                  decoration: routine['checked'] ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 루틴 텍스트 수정 다이얼로그
  void _editRoutineText(int index) {
    final controller = TextEditingController(text: _routines[index]['text']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5E6D3),
          title: const Text('루틴 수정', style: TextStyle(color: Color(0xFF6B4E3D))),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xFF6B4E3D)),
            decoration: InputDecoration(
              hintText: '루틴 내용을 입력하세요',
              hintStyle: TextStyle(color: const Color(0xFF8B6B47).withValues(alpha: 0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: const Color(0xFF8B6B47).withValues(alpha: 0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF8B6B47)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Color(0xFF8B6B47))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _routines[index]['text'] = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('저장', style: TextStyle(color: Color(0xFF8B6B47), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }


  /// 일정 블록(저장된 것 또는 임시)을 그립니다.
  Widget _buildScheduleBlock(ScheduleEntry entry, {bool isPreview = false}) {
    // 1분당 높이 (0.833...)
    final double minuteHeight = _hourHeight / 60.0;
    
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
      // 4. '왼쪽'을 시간표 너비 + 여백으로 설정
      left: _timelineWidth + 4.0, 
      right: 4.0, 
      height: height,
      child: Opacity(
        opacity: isPreview ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: entry.category.color.withValues(alpha: isPreview ? 0.5 : 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: entry.category.color, width: 1.5),
          ),
          child: Text(
            entry.category.name,
            style: const TextStyle(
              color: Color(0xFFF5E6D3),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// 드래그를 감지하는 투명한 위젯
  Widget _buildGestureDetector() {
    return Positioned.fill(
      // 5. '왼쪽'을 시간표 너비로 설정 (시간표 위는 드래그 안 되게)
      left: _timelineWidth, 
      child: GestureDetector(
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
      ),
    );
  }

  // --- 로직 메서드 ---

  /// Y축 오프셋(dy)을 30분 단위의 TimeOfDay로 변환합니다. (hourHeight 변경됨)
  TimeOfDay _getTimeFromOffset(double dy) {
    final double minuteHeight = _hourHeight / 60.0;
    double totalMinutes = dy / minuteHeight;
    
    int snappedMinutes = (totalMinutes / 30).round() * 30;
    snappedMinutes = math.max(0, snappedMinutes); 

    int hour = (snappedMinutes ~/ 60) % 24; 
    int minute = snappedMinutes % 60;

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// 드래그 시작
  void _onDragStart(DragStartDetails details) {
    _dragStartTime = _getTimeFromOffset(details.localPosition.dy);
    _dragEndTime = _dragStartTime; 

    setState(() {
      _previewEntry = ScheduleEntry(
        startTime: _dragStartTime!,
        endTime: _dragEndTime!,
        category: ActivityCategory(
          name: '...',
          icon: Icons.drag_handle,
          color: Colors.grey.shade600,
        ),
      );
    });
  }

  /// 드래그 중
  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragStartTime == null) return;

    _dragEndTime = _getTimeFromOffset(details.localPosition.dy);

    final startTimeInMinutes = _dragStartTime!.hour * 60 + _dragStartTime!.minute;
    final endTimeInMinutes = _dragEndTime!.hour * 60 + _dragEndTime!.minute;

    setState(() {
      _previewEntry = ScheduleEntry(
        startTime: startTimeInMinutes < endTimeInMinutes ? _dragStartTime! : _dragEndTime!,
        endTime: startTimeInMinutes < endTimeInMinutes ? _dragEndTime! : _dragStartTime!,
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

  /// 카테고리 선택 바텀 시트
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5E6D3),
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
                  color: Color(0xFF6B4E3D),
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
                          Icon(category.icon, color: category.color, size: 22),
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

// --- 4. 타임라인 배경을 그리는 CustomPainter (수정됨) ---

class TimelinePainter extends CustomPainter {
  final double hourHeight;
  final double timelineWidth; // timeLabelWidth -> timelineWidth로 이름 변경
  final BuildContext context;

  TimelinePainter({
    required this.hourHeight,
    required this.timelineWidth,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF8B6B47).withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    final dotPaint = Paint()
      ..color = const Color(0xFF8B6B47).withValues(alpha: 0.4);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final textStyle = const TextStyle(
      color: Color(0xFF8B6B47),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i < 24; i++) {
      final y = i * hourHeight;

      // Draw hour label (00, 01, ...)
      textPainter.text = TextSpan(
        text: '${i.toString().padLeft(2, '0')}',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (timelineWidth - textPainter.width) / 2, // 얇은 시간표 영역 중앙 정렬
          y - (textPainter.height / 2),
        ),
      );

      // Draw horizontal line for the hour
      canvas.drawLine(
        Offset(timelineWidth, y), // 얇은 시간표 너비에서 시작
        Offset(size.width, y), // 스크롤 영역 끝까지
        linePaint,
      );

      // Draw dot for the half-hour
      final yHalf = y + hourHeight / 2;
      canvas.drawCircle(
        Offset(timelineWidth, yHalf), // 얇은 시간표 너비에 점을 그림
        2.0, 
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return oldDelegate.hourHeight != hourHeight ||
           oldDelegate.timelineWidth != timelineWidth ||
           oldDelegate.context != context;
  }
}

