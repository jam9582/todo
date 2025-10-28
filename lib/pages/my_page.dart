import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: AppColors.darkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text(
          '마이페이지',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.darkBrown,
          ),
        ),
      ),
    );
  }
}
