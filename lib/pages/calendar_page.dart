import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

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
      body: const Center(
        child: Text(
          '캘린더 페이지',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.darkBrown,
          ),
        ),
      ),
    );
  }
}
