/// Status of a practice entry.
enum PracticeStatus {
  inProgress('In progress'),
  done('Done');

  final String label;
  const PracticeStatus(this.label);
}

/// Data model representing a single student practice diary entry.
class PracticeEntry {
  final String id;
  final String date;
  final String title;
  final String description;
  final double hours;
  final List<String> skills;
  final PracticeStatus status;

  const PracticeEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.hours,
    required this.skills,
    required this.status,
  });

  PracticeEntry copyWith({
    String? id,
    String? date,
    String? title,
    String? description,
    double? hours,
    List<String>? skills,
    PracticeStatus? status,
  }) {
    return PracticeEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      skills: skills ?? this.skills,
      status: status ?? this.status,
    );
  }
}
