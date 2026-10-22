import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'core/config/sentry_config.dart';
import 'firebase_options.dart';

/// Application entry point initializing Firebase and Sentry.
Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = SentryConfig.dsn;
      options.tracesSampleRate = 0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(const PracticeTrackerApp());
    },
  );
}
