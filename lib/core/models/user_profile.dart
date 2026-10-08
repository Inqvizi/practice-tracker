/// Model representing a student user profile.
class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String group;
  final String specialty;
  final String role;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.group,
    required this.specialty,
    this.role = 'Student',
  });

  String get fullName => '$firstName $lastName';
  String get initials {
    final firstChar = firstName.isNotEmpty ? firstName[0] : '';
    final lastChar = lastName.isNotEmpty ? lastName[0] : '';
    return '$firstChar$lastChar'.toUpperCase();
  }

  String get groupAndSpecialty => '$group · $specialty';

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? group,
    String? specialty,
    String? role,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      group: group ?? this.group,
      specialty: specialty ?? this.specialty,
      role: role ?? this.role,
    );
  }
}
