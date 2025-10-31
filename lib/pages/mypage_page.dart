import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 마이페이지 (사용자 프로필 및 설정)
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 사용자 프로필 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.primaryBrown.withValues(alpha: 0.1),
              ),
              child: Column(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryBrown,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 사용자 이름
                  Text(
                    '사용자',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 사용자 이메일
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryBrown,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. 설정 메뉴 섹션
            _buildSection(
              title: '설정',
              items: [
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: '알림 설정',
                  onTap: () {
                    // TODO: 알림 설정 페이지로 이동
                  },
                ),
                _buildMenuItem(
                  icon: Icons.category_outlined,
                  title: '카테고리 관리',
                  onTap: () {
                    // TODO: 카테고리 관리 페이지로 이동
                  },
                ),
                _buildMenuItem(
                  icon: Icons.palette_outlined,
                  title: '테마 설정',
                  onTap: () {
                    // TODO: 테마 설정 페이지로 이동
                  },
                ),
                _buildMenuItem(
                  icon: Icons.backup_outlined,
                  title: '데이터 백업/복원',
                  onTap: () {
                    // TODO: 백업 페이지로 이동
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. 프리미엄 섹션
            _buildSection(
              title: '프리미엄',
              items: [
                _buildMenuItem(
                  icon: Icons.workspace_premium,
                  title: '프리미엄 구독',
                  subtitle: '광고 제거 및 추가 기능',
                  onTap: () {
                    // TODO: 프리미엄 구독 페이지로 이동
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. 앱 정보 섹션
            _buildSection(
              title: '앱 정보',
              items: [
                _buildMenuItem(
                  icon: Icons.info_outlined,
                  title: '버전 정보',
                  subtitle: 'v1.0.0',
                  onTap: () {
                    // TODO: 버전 정보 표시
                  },
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: '개인정보 처리방침',
                  onTap: () {
                    // TODO: 개인정보 처리방침 페이지로 이동
                  },
                ),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: '이용약관',
                  onTap: () {
                    // TODO: 이용약관 페이지로 이동
                  },
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: '고객센터',
                  onTap: () {
                    // TODO: 고객센터 페이지로 이동
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 5. 계정 관리 섹션
            _buildSection(
              title: '계정',
              items: [
                _buildMenuItem(
                  icon: Icons.logout,
                  title: '로그아웃',
                  titleColor: AppColors.primaryBrown,
                  onTap: () {
                    // TODO: 로그아웃 처리
                  },
                ),
                _buildMenuItem(
                  icon: Icons.delete_outline,
                  title: '회원 탈퇴',
                  titleColor: Colors.red.shade300,
                  onTap: () {
                    // TODO: 회원 탈퇴 처리
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 섹션 빌더
  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBrown.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  /// 메뉴 아이템 빌더
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ?? AppColors.darkBrown,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: titleColor ?? AppColors.darkBrown,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBrown.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.primaryBrown.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
