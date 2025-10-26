import 'package:flutter/material.dart';
import 'screens/schedule_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const ProtoApp());
}

class ProtoApp extends StatelessWidget {
  const ProtoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루 일과',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
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
            // 아이폰 규격 (402 x 874)
            child: const SizedBox(
              width: 402,
              height: 874,
              child: ScheduleScreen(), // 실제 앱 화면
            ),
          ),
        ),
      ),
    );
  }
}
