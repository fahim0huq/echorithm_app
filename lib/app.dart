import 'package:flutter/material.dart';

import 'Data/service/settings_service.dart';
import 'ui/screens/bottom_nav_screen.dart';
import 'ui/utils/app_theme.dart';

class EchorithmApp extends StatelessWidget {
  final List<String> interests;
  final bool isFirstLaunch;

  const EchorithmApp({super.key, required this.interests, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Echorithm',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: BottomNavScreen(interests: interests, isFirstLaunch: isFirstLaunch),
        );
      },
    );
  }
}
