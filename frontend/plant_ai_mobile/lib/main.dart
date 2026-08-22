import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';
import 'package:plant_ai_mobile/core/theme/app_theme.dart';
import 'package:plant_ai_mobile/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlantAIApp());
}

class PlantAIApp extends StatefulWidget {
  const PlantAIApp({super.key});

  @override
  State<PlantAIApp> createState() => _PlantAIAppState();
}

class _PlantAIAppState extends State<PlantAIApp> {
  final _controller = AppController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncSystemUi);
    _syncSystemUi();
  }

  @override
  void dispose() {
    _controller.removeListener(_syncSystemUi);
    _controller.dispose();
    super.dispose();
  }

  void _syncSystemUi() {
    final isDark = _controller.isDark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? AppColors.dark.background : AppColors.light.background,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AppScope(
          controller: _controller,
          child: MaterialApp(
            title: 'PlantAI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _controller.themeMode,
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}
