import 'package:flutter/material.dart';
import 'auth_repository.dart';

/// Власний InheritedWidget для передачі [AuthRepository] вниз по дереву віджетів
/// без використання сторонніх бібліотек стану (Provider/Bloc), згідно з обмеженнями ЛР4.
class AuthScope extends InheritedWidget {
  final AuthRepository repository;

  const AuthScope({
    super.key,
    required this.repository,
    required super.child,
  });

  /// Отримання екземпляра [AuthRepository] з найближчого [AuthScope] у дереві.
  static AuthRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in current BuildContext');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) =>
      repository != oldWidget.repository;
}
