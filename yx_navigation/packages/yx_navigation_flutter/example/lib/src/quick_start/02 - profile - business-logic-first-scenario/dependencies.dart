import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'profile_navigation_interactor.dart';
import 'profile_routes.dart';

/// App-level dependencies for the business-logic-first scenario.
///
/// RouteNodeStateManager is owned at the Dependencies layer and injected into
/// ProfileNavigationInteractor through its constructor. This avoids
/// GlobalKey juggling and yields a cleaner architecture.
final class Dependencies {
  final ProfileNavigationInteractor profileInteractor;

  /// Direct state-manager handle for the UI layer.
  final RouteNodeStateManager stateManager;

  const Dependencies._({
    required this.profileInteractor,
    required this.stateManager,
  });

  factory Dependencies() {
    // 1. Create the root RouteNodeStateManager with the initial profile state.
    final stateManager = RouteNodeStateManager(
      routeNode: ProfileRoutes.home.toNode(),
    );

    // 2. Create ProfileNavigationInteractor and inject the state manager.
    final profileInteractor = ProfileNavigationInteractor(
      stateManager: stateManager,
    );

    return Dependencies._(
      profileInteractor: profileInteractor,
      stateManager: stateManager,
    );
  }
}

/// Scope that exposes Dependencies through an InheritedWidget.
final class DependenciesScope extends InheritedWidget {
  const DependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  /// Resolves Dependencies from the given context.
  static Dependencies of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<DependenciesScope>()
        : context.getInheritedWidgetOfExactType<DependenciesScope>();

    if (scope == null) {
      throw FlutterError(
        'DependenciesScope not found in context. '
        'Make sure to wrap your app with DependenciesScope.',
      );
    }

    return scope.dependencies;
  }

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(covariant DependenciesScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
