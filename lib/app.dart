import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/auth_scope.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/entries/entries_screen.dart';
import 'features/entries/entry_form_screen.dart';
import 'features/profile/profile_screen.dart';

/// Main application widget providing [AuthScope], [AuthGate], theme, and analytics.
class PracticeTrackerApp extends StatefulWidget {
  const PracticeTrackerApp({super.key});

  @override
  State<PracticeTrackerApp> createState() => _PracticeTrackerAppState();
}

class _PracticeTrackerAppState extends State<PracticeTrackerApp> {
  final _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      repository: _authRepository,
      child: MaterialApp(
        title: 'Practice Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.dashboard: (context) => const DashboardScreen(),
          AppRoutes.entries: (context) => const EntriesScreen(),
          AppRoutes.entryForm: (context) => const EntryFormScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
