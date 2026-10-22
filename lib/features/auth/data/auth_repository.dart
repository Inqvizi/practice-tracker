import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/auth_failure.dart';

/// Central repository managing Firebase Authentication operations.
/// Intercepts [FirebaseAuthException] errors and converts them to [AuthFailure].
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Stream of user authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Current authenticated user or null.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Registers a new user via Email/Password and stores their full name.
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
        await user.updateDisplayName(fullName);
        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Failed to create account. Please try again later.');
    }
  }

  /// Signs in a user using Email and Password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Failed to sign in. Please try again.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Failed to sign out.');
    }
  }

  /// Sends a password reset email to the specified address.
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Failed to send password reset email.');
    }
  }

  /// Updates display name (first and last name) of the current user.
  Future<void> updateDisplayName({
    required String firstName,
    required String lastName,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailure('User is not authenticated.');
    }
    try {
      final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
      await user.updateDisplayName(fullName);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Failed to update display name.');
    }
  }

  /// Updates profile photo URL for the current user.
  /// Requires valid HTTPS scheme.
  Future<void> updatePhotoUrl(String url) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailure('User is not authenticated.');
    }

    final trimmedUrl = url.trim();
    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null || uri.scheme.toLowerCase() != 'https' || !uri.hasAuthority) {
      throw const AuthFailure('Photo URL must start with a valid https:// protocol.');
    }

    try {
      await user.updatePhotoURL(trimmedUrl);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Failed to update profile photo.');
    }
  }

  /// Changes password with automatic reauthentication on requires-recent-login.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailure('User is not authenticated.');
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final email = user.email;
        if (email == null) {
          throw const AuthFailure('Action requires user email.');
        }

        try {
          final credential = EmailAuthProvider.credential(
            email: email,
            password: currentPassword,
          );
          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(newPassword);
        } on FirebaseAuthException catch (reauthEx) {
          if (reauthEx.code == 'wrong-password' ||
              reauthEx.code == 'invalid-credential') {
            throw const AuthFailure('Incorrect current password.');
          }
          throw AuthFailure.fromFirebaseAuthException(reauthEx);
        }
      } else {
        throw AuthFailure.fromFirebaseAuthException(e);
      }
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const AuthFailure('Failed to change password. Please try again later.');
    }
  }
}
