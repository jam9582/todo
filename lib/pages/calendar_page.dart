import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/constants.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '캘린더',
          style: TextStyle(
            color: AppColors.darkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 캘린더
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            // 스타일링
            calendarStyle: CalendarStyle(
              // 오늘 날짜
              todayDecoration: BoxDecoration(
                color: AppColors.lightBrown,
                shape: BoxShape.circle,
              ),
              // 선택된 날짜
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryBrown,
                shape: BoxShape.circle,
              ),
              // 주말
              weekendTextStyle: const TextStyle(color: Colors.red),
              // 기본 텍스트
              defaultTextStyle: const TextStyle(color: AppColors.darkBrown),
              // 다른 달의 날짜
              outsideTextStyle: TextStyle(color: AppColors.primaryBrown.withValues(alpha: 0.3)),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: AppColors.primaryBrown,
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: const TextStyle(
                color: AppColors.background,
                fontSize: 13,
              ),
              titleTextStyle: const TextStyle(
                color: AppColors.darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: AppColors.primaryBrown,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: AppColors.primaryBrown,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.darkBrown),
              weekendStyle: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 20),
          // 선택된 날짜 표시
          if (_selectedDay != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '이 날의 일정',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '아직 일정이 없습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkBrown,
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
}
