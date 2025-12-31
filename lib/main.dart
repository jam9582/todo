import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  runApp(const ProtoApp());
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
