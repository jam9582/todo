import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'layouts/main_layout.dart';
import 'providers/schedule_provider.dart';
import 'providers/category_provider.dart';
import 'services/storage_service.dart';
import 'utils/constants.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화 (StorageService에서 Box 열기 및 Adapter 등록)
  await StorageService.init();

  runApp(
    DevicePreview(
      // 개발 모드(디버그/프로파일)에서만 활성화, 릴리즈(프로덕션) 빌드에서는 비활성화
      enabled: !kReleaseMode,
      builder: (context) => const ProtoApp(),
    ),
  );
}

class ProtoApp extends StatelessWidget {
  const ProtoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        // Device Preview 설정
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,

        title: '하루 일과',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.background,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainLayout(),
      ),
    );
  }
}
