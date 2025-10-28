import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/calendar_page.dart';
import '../pages/statistics_page.dart';
import '../pages/my_page.dart';
import 'bottom_navigation_bar.dart';
import '../utils/constants.dart';

class MainLayout extends StatefulWidget {
  final bool isPremiumUser; // 유료 사용자 여부

  const MainLayout({
    super.key,
    this.isPremiumUser = false, // 기본값: 무료 사용자
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // 페이지 목록
  final List<Widget> _pages = const [
    HomePage(),
    CalendarPage(),
    StatisticsPage(),
    MyPage(),
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 최상단: 광고 영역 (유료 사용자면 숨김)
          if (!widget.isPremiumUser)
            Container(
              height: 50,
              color: AppColors.lightBrown.withValues(alpha: 0.3),
              child: const Center(
                child: Text(
                  '광고 영역',
                  style: TextStyle(
                    color: AppColors.darkBrown,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // 중간: 페이지 내용 (자동으로 확장됨)
          Expanded(
            child: _pages[_currentIndex],
          ),

          // 최하단: 네비게이션 바 (항상 고정)
          CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onNavigationTap,
          ),
        ],
      ),
    );
  }
}
