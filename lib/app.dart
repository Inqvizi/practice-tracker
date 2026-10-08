import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/entries/entries_screen.dart';
import 'features/entries/entry_form_screen.dart';
import 'features/profile/profile_screen.dart';

/// Root MaterialApp component configuring theme, title, and application routes.
class PracticeTrackerApp extends StatelessWidget {
  const PracticeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Practice Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
        AppRoutes.entries: (context) => const EntriesScreen(),
        AppRoutes.entryForm: (context) => const EntryFormScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
      },
    );
  }
}
