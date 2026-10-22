import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/auth_failure.dart';

/// Єдиний репозиторій для роботи з Firebase Authentication.
/// Всі помилки [FirebaseAuthException] перехоплюються і конвертуються в [AuthFailure].
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Потік змін стану автентифікації користувача.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Поточний авторизований користувач або null.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Реєстрація нового користувача через Email/Password зі збереженням повного імені.
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
      throw const AuthFailure('Не вдалося зареєструватися. Спробуйте пізніше.');
    }
  }

  /// Вхід користувача за допомогою Email та пароля.
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
      throw const AuthFailure('Не вдалося увійти. Спробуйте ще раз.');
    }
  }

  /// Вихід користувача із системи.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Помилка під час виходу з облікового запису.');
    }
  }

  /// Надсилання листа для відновлення пароля на вказаний Email.
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Не вдалося надіслати лист для відновлення.');
    }
  }

  /// Оновлення імені та прізвища поточного користувача.
  Future<void> updateDisplayName({
    required String firstName,
    required String lastName,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailure('Користувач не авторизований.');
    }
    try {
      final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
      await user.updateDisplayName(fullName);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Не вдалося оновити імʼя користувача.');
    }
  }

  /// Оновлення URL фотографії профілю користувача.
  /// Дозволяються виключно безпечні посилання з протоколом HTTPS.
  Future<void> updatePhotoUrl(String url) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailure('Користувач не авторизований.');
    }

    final trimmedUrl = url.trim();
    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null || uri.scheme.toLowerCase() != 'https' || !uri.hasAuthority) {
      throw const AuthFailure('Посилання на фото повинно мати дійсний протокол HTTPS.');
    }

    try {
      await user.updatePhotoURL(trimmedUrl);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseAuthException(e);
    } catch (_) {
      throw const AuthFailure('Не вдалося оновити фотографію профілю.');
    }
  }

  /// Зміна пароля з автоматичною реавтентифікацією при requires-recent-login.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailure('Користувач не авторизований.');
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final email = user.email;
        if (email == null) {
          throw const AuthFailure('Неможливо виконати дію: відсутній email користувача.');
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
            throw const AuthFailure('Неправильний поточний пароль.');
          }
          throw AuthFailure.fromFirebaseAuthException(reauthEx);
        }
      } else {
        throw AuthFailure.fromFirebaseAuthException(e);
      }
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const AuthFailure('Не вдалося змінити пароль. Спробуйте пізніше.');
    }
  }
}
