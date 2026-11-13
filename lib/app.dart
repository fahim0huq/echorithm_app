import 'package:flutter/material.dart';

import 'ui/screens/home_screen.dart';
import 'ui/utils/app_theme.dart';

class EchorithmApp extends StatelessWidget {
  final List<String> interests;

  const EchorithmApp({super.key, required this.interests});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echorithm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(interests: interests),
    );
  }
}
