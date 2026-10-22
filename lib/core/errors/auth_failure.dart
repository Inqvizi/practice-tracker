import 'package:firebase_auth/firebase_auth.dart';

/// Клас для представлення помилок автентифікації зі зрозумілими повідомленнями українською мовою.
class AuthFailure implements Exception {
  final String message;
  final String? code;

  const AuthFailure(this.message, {this.code});

  /// Створює [AuthFailure] на основі коду [FirebaseAuthException].
  factory AuthFailure.fromFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return AuthFailure(
          'Некоректний формат електронної пошти.',
          code: exception.code,
        );
      case 'user-not-found':
        return AuthFailure(
          'Користувача з такою електронною поштою не знайдено.',
          code: exception.code,
        );
      case 'wrong-password':
        return AuthFailure(
          'Неправильний пароль.',
          code: exception.code,
        );
      case 'invalid-credential':
        return AuthFailure(
          'Не вдалося увійти. Перевірте email і пароль.',
          code: exception.code,
        );
      case 'email-already-in-use':
        return AuthFailure(
          'Обліковий запис із цією електронною поштою вже існує.',
          code: exception.code,
        );
      case 'weak-password':
        return AuthFailure(
          'Пароль занадто простий. Використовуйте щонайменше 8 символів.',
          code: exception.code,
        );
      case 'too-many-requests':
        return AuthFailure(
          'Забагато спроб. Будь ласка, зачекайте та спробуйте пізніше.',
          code: exception.code,
        );
      case 'network-request-failed':
        return AuthFailure(
          'Помилка мережі. Перевірте підключення до інтернету.',
          code: exception.code,
        );
      case 'requires-recent-login':
        return AuthFailure(
          'Ця дія потребує повторної авторизації. Увійдіть знову.',
          code: exception.code,
        );
      case 'user-disabled':
        return AuthFailure(
          'Цей обліковий запис було заблоковано.',
          code: exception.code,
        );
      case 'operation-not-allowed':
        return AuthFailure(
          'Цей спосіб входу вимкнено адміністратором.',
          code: exception.code,
        );
      default:
        return AuthFailure(
          'Сталася помилка. Спробуйте ще раз.',
          code: exception.code,
        );
    }
  }

  @override
  String toString() => message;
}
