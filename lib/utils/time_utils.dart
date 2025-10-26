import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 시간 관련 유틸리티 함수들
class TimeUtils {
  /// Y축 오프셋(dy)을 30분 단위의 TimeOfDay로 변환
  static TimeOfDay getTimeFromOffset(double dy, double hourHeight) {
    final double minuteHeight = hourHeight / 60.0;
    double totalMinutes = dy / minuteHeight;

    int snappedMinutes = (totalMinutes / 30).round() * 30;
    snappedMinutes = math.max(0, snappedMinutes);

    int hour = (snappedMinutes ~/ 60) % 24;
    int minute = snappedMinutes % 60;

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// 분을 시간:분 형식으로 변환
  static String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}시간 ${mins}분';
    } else {
      return '${mins}분';
    }
  }

  /// TimeOfDay를 총 분으로 변환
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  /// 두 TimeOfDay 사이의 시간 차이(분)를 계산
  static int getTimeDifference(TimeOfDay start, TimeOfDay end) {
    int startMinutes = timeOfDayToMinutes(start);
    int endMinutes = timeOfDayToMinutes(end);

    // 자정(00:00)인 경우 24:00으로 처리
    if (end.hour == 0 && end.minute == 0) {
      endMinutes = 24 * 60;
    }

    return endMinutes - startMinutes;
  }
}
