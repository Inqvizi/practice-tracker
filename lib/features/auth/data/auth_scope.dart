import 'package:flutter/material.dart';
import 'auth_repository.dart';

/// Custom InheritedWidget for passing [AuthRepository] down the widget tree
/// without third-party state management libraries (Provider/Bloc).
class AuthScope extends InheritedWidget {
  final AuthRepository repository;

  const AuthScope({
    super.key,
    required this.repository,
    required super.child,
  });

  /// Retrieves the [AuthRepository] instance from the nearest [AuthScope] in the tree.
  static AuthRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in current BuildContext');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) =>
      repository != oldWidget.repository;
}
