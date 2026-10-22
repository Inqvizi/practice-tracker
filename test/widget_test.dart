import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice_tracker/core/errors/auth_failure.dart';
import 'package:practice_tracker/core/validators/validators.dart';

void main() {
  group('Validators tests', () {
    test('requiredField validates non-empty strings', () {
      expect(Validators.requiredField(null), isNotNull);
      expect(Validators.requiredField(''), isNotNull);
      expect(Validators.requiredField('   '), isNotNull);
      expect(Validators.requiredField('Valuable text'), isNull);
    });

    test('email validator verifies format correctly', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('student@'), isNotNull);
      expect(Validators.email('student@university.edu'), isNull);
      expect(Validators.email('oleksandr.firko@lpnu.ua'), isNull);
    });

    test('password validator enforces minimum 8 characters', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
      expect(Validators.password('securePassword2025!'), isNull);
    });

    test('confirmPassword ensures password parity', () {
      expect(Validators.confirmPassword(null, 'secret123'), isNotNull);
      expect(Validators.confirmPassword('', 'secret123'), isNotNull);
      expect(Validators.confirmPassword('mismatch', 'secret123'), isNotNull);
      expect(Validators.confirmPassword('secret123', 'secret123'), isNull);
    });
  });

  group('AuthFailure mapping tests', () {
    test('maps Firebase exception codes to user-friendly English messages', () {
      final userNotFound = AuthFailure.fromFirebaseAuthException(
        FirebaseAuthException(code: 'user-not-found'),
      );
      expect(userNotFound.message, contains('No user found'));

      final wrongPassword = AuthFailure.fromFirebaseAuthException(
        FirebaseAuthException(code: 'wrong-password'),
      );
      expect(wrongPassword.message, contains('Wrong password'));

      final emailInUse = AuthFailure.fromFirebaseAuthException(
        FirebaseAuthException(code: 'email-already-in-use'),
      );
      expect(emailInUse.message, contains('already exists'));

      final weakPassword = AuthFailure.fromFirebaseAuthException(
        FirebaseAuthException(code: 'weak-password'),
      );
      expect(weakPassword.message, contains('too weak'));

      final networkFailed = AuthFailure.fromFirebaseAuthException(
        FirebaseAuthException(code: 'network-request-failed'),
      );
      expect(networkFailed.message, contains('Network connection'));
    });
  });
}
