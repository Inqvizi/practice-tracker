import '../models/practice_entry.dart';
import '../models/user_profile.dart';

/// Static mock data for Practice Tracker application.
abstract final class MockData {
  /// STUB (ЛР4): група не зберігається у Firebase Auth
  static const String defaultAcademicGroup = 'PZ-32 · Software Engineering';

  /// STUB (ЛР4): моковий профіль студента для збереження зворотної сумісності з ЛР2/ЛР3
  static const UserProfile currentUser = UserProfile(
    firstName: 'Oleksandr',
    lastName: 'Firko',
    email: 'oleksandr.firko@university.edu',
    group: 'PZ-32',
    specialty: 'Software Engineering',
    role: 'Student',
  );

  /// STUB (ЛР4): дані з Cloud Firestore, буде реалізовано пізніше
  static const List<PracticeEntry> initialEntries = [
    PracticeEntry(
      id: 'entry-1',
      date: 'May 24, 2025',
      title: 'REST API authentication',
      description: 'Implemented JWT authentication and refresh token handling.',
      hours: 3.5,
      skills: ['Dart', 'REST API', 'JWT'],
      status: PracticeStatus.done,
    ),
    PracticeEntry(
      id: 'entry-2',
      date: 'May 22, 2025',
      title: 'Database schema update',
      description: 'Added migrations and optimized queries for practice entries.',
      hours: 4.0,
      skills: ['PostgreSQL', 'SQL'],
      status: PracticeStatus.done,
    ),
    PracticeEntry(
      id: 'entry-3',
      date: 'May 20, 2025',
      title: 'Unit test coverage',
      description: 'Expanded service-layer tests and documented edge cases.',
      hours: 2.5,
      skills: ['Unit Testing', 'Dart'],
      status: PracticeStatus.inProgress,
    ),
    PracticeEntry(
      id: 'entry-4',
      date: 'May 17, 2025',
      title: 'Sprint planning',
      description: 'Prepared engineering tasks and estimates for the next sprint.',
      hours: 2.0,
      skills: ['Agile', 'Scrum'],
      status: PracticeStatus.done,
    ),
    PracticeEntry(
      id: 'entry-5',
      date: 'May 15, 2025',
      title: 'UI component design system',
      description: 'Developed responsive design system tokens and reusable widgets.',
      hours: 3.5,
      skills: ['Flutter', 'Design System'],
      status: PracticeStatus.done,
    ),
  ];
}
