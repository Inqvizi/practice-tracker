/// Валідатори для полів введення форм автентифікації та профілю.
abstract final class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Перевірка обов'язкового поля на непорожнє значення.
  static String? requiredField(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'Поле "$fieldName" є обовʼязковим.'
          : 'Це поле є обовʼязковим.';
    }
    return null;
  }

  /// Валідація коректності формату електронної пошти.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть адресу електронної пошти.';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Некоректний формат email (наприклад, user@university.edu).';
    }
    return null;
  }

  /// Валідація пароля (щонайменше 8 символів за вимогами методички ЛР4).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль.';
    }
    if (value.length < 8) {
      return 'Пароль повинен містити щонайменше 8 символів.';
    }
    return null;
  }

  /// Перевірка збігу пароля та його підтвердження.
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Підтвердіть пароль.';
    }
    if (value != original) {
      return 'Паролі не збігаються.';
    }
    return null;
  }
}
