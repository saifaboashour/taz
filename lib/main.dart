import 'package:flutter/material.dart';
import 'package:taz/core/database/app_database.dart';
import 'package:taz/features/home/presentation/home_screen.dart';

import 'app/theme/app_theme.dart';
import 'features/habits/domain/repositories/drift_habit_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Taz());
}

class Taz extends StatefulWidget {
  const Taz({super.key});

  @override
  State<Taz> createState() => _TazState();
}

class _TazState extends State<Taz> {
  late final AppDatabase database;
  late final DriftHabitRepository repository;

  @override
  void initState() {
    super.initState();

    database = AppDatabase();
    repository = DriftHabitRepository(database);
  }

  @override
  void dispose() {
    database.close();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAZ',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      home: HomeScreen(habitRepository: repository),
    );
  }
}
