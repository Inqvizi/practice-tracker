import 'package:firebase_auth/firebase_auth.dart';

/// Class representing authentication failures with user-friendly English messages.
class AuthFailure implements Exception {
  final String message;
  final String? code;

  const AuthFailure(this.message, {this.code});

  /// Creates an [AuthFailure] based on the code from [FirebaseAuthException].
  factory AuthFailure.fromFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return AuthFailure(
          'Invalid email address format.',
          code: exception.code,
        );
      case 'user-not-found':
        return AuthFailure(
          'No user found with this email address.',
          code: exception.code,
        );
      case 'wrong-password':
        return AuthFailure(
          'Wrong password provided.',
          code: exception.code,
        );
      case 'invalid-credential':
        return AuthFailure(
          'Invalid credentials. Please verify your email and password.',
          code: exception.code,
        );
      case 'email-already-in-use':
        return AuthFailure(
          'An account with this email already exists.',
          code: exception.code,
        );
      case 'weak-password':
        return AuthFailure(
          'Password is too weak. Please use at least 8 characters.',
          code: exception.code,
        );
      case 'too-many-requests':
        return AuthFailure(
          'Too many failed attempts. Please try again later.',
          code: exception.code,
        );
      case 'network-request-failed':
        return AuthFailure(
          'Network connection error. Please check your internet.',
          code: exception.code,
        );
      case 'requires-recent-login':
        return AuthFailure(
          'This operation requires recent authentication. Please log in again.',
          code: exception.code,
        );
      case 'user-disabled':
        return AuthFailure(
          'This user account has been disabled.',
          code: exception.code,
        );
      case 'operation-not-allowed':
        return AuthFailure(
          'Email/password sign-in is not enabled.',
          code: exception.code,
        );
      default:
        return AuthFailure(
          'An authentication error occurred. Please try again.',
          code: exception.code,
        );
    }
  }

  @override
  String toString() => message;
}
