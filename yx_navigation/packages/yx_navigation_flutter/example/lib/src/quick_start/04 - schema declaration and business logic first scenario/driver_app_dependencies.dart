import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'driver_navigation_interactor.dart';
import 'driver_routes.dart';

/// App-level dependencies for the combined approach:
/// Schema Declaration + Business Logic First.
///
/// Creates and owns the main dependencies:
/// - RouteNodeStateManager - root navigation state manager
/// - NavigationController - profile feature controller (isolated)
/// - DriverNavigationInteractor - main navigation interactor (isolated)
final class DriverAppDependencies {
  /// Root navigation state manager.
  final RouteNodeStateManager stateManager;
  final LateInitGuardConfiguration routeNodeGuard;

  /// Navigation controller for the profile feature.
  /// It is handed to ProfileFeatureDependencies.embedded() inside the feature.
  final NavigationController profileNavigationController;

  /// Main driver-app navigation interactor.
  final DriverNavigationInteractor driverInteractor;

  const DriverAppDependencies._({
    required this.stateManager,
    required this.profileNavigationController,
    required this.driverInteractor,
    required this.routeNodeGuard,
  });

  factory DriverAppDependencies() {
    final routeNodeGuard = LateInitGuardConfiguration();

    // 1. Create the root RouteNodeStateManager with the initial state.
    final stateManager = RouteNodeStateManager(
      routeNode: DriverRoutes.login.toNode(),
      routeNodeGuard: routeNodeGuard,
    );

    // 2. Create the NavigationController for the profile feature.
    // This controller is passed into ProfileFeatureDependencies.embedded()
    // from the feature itself via its outletBuilder.
    final profileNavigationController = NavigationController.node(
      stateManager: stateManager,
      nodeResolver: RouteNodeResolver.id(route: DriverRoutes.profile),
    );

    // 3. Create a fully isolated DriverNavigationInteractor.
    final driverInteractor = DriverNavigationInteractor(
      stateManager: stateManager,
    );

    return DriverAppDependencies._(
      stateManager: stateManager,
      profileNavigationController: profileNavigationController,
      driverInteractor: driverInteractor,
      routeNodeGuard: routeNodeGuard,
    );
  }
}

/// Scope that exposes dependencies through an InheritedWidget.
///
/// Uses the classic InheritedWidget pattern for DI. Exposes only the main
/// app dependencies. Features build their own dependencies and receive
/// only a NavigationController.
final class DriverAppDependenciesScope extends InheritedWidget {
  const DriverAppDependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  /// Resolves Dependencies from the given context.
  static DriverAppDependencies of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context
            .dependOnInheritedWidgetOfExactType<DriverAppDependenciesScope>()
        : context.getInheritedWidgetOfExactType<DriverAppDependenciesScope>();

    if (scope == null) {
      throw FlutterError(
        'DependenciesScope not found in context. '
        'Make sure to wrap your app with DependenciesScope.',
      );
    }

    return scope.dependencies;
  }

  final DriverAppDependencies dependencies;

  @override
  bool updateShouldNotify(DriverAppDependenciesScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
