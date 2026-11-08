import 'package:flutter/material.dart';
import 'package:taz/features/home/presentation/home_screen.dart';

import 'app/theme/app_theme.dart';

void main() {
  runApp(const Taz());
}

class Taz extends StatelessWidget {
  const Taz({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAZ',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
