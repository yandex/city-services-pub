import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'profile_navigation_interactor.dart';
import 'profile_routes.dart';

/// Dependencies for the profile feature.
///
/// Supports two modes:
/// 1. Standalone - creates its own RouteNodeStateManager
/// 2. Embedded - receives a NavigationController from the outside
final class ProfileFeatureDependencies {
  final ProfileNavigationInteractor profileInteractor;

  /// State-manager handle (only set in standalone mode).
  final RouteNodeStateManager? stateManager;

  /// True when the feature runs in standalone mode.
  bool get isStandalone => stateManager != null;

  /// True when the feature runs in embedded mode.
  bool get isEmbedded => stateManager == null;

  const ProfileFeatureDependencies._({
    required this.profileInteractor,
    this.stateManager,
  });

  /// Factory for standalone mode - the feature runs on its own.
  factory ProfileFeatureDependencies.standalone() {
    // 1. Create our own RouteNodeStateManager with the initial profile state.
    final stateManager = RouteNodeStateManager(
      routeNode: ProfileRoutes.home.toNode(),
    );

    // 2. Create ProfileNavigationInteractor with the owned state manager.
    final profileInteractor = ProfileNavigationInteractor(
      navigationController: stateManager,
    );

    return ProfileFeatureDependencies._(
      profileInteractor: profileInteractor,
      stateManager: stateManager,
    );
  }

  /// Factory for embedded mode - the feature is hosted inside another app.
  factory ProfileFeatureDependencies.embedded({
    required NavigationController navigationController,
  }) {
    // Create ProfileNavigationInteractor with the external controller.
    final profileInteractor = ProfileNavigationInteractor(
      navigationController: navigationController,
    );

    return ProfileFeatureDependencies._(
      profileInteractor: profileInteractor,
      stateManager: null, // Embedded mode does not own a state manager.
    );
  }
}

/// Scope that exposes the profile feature's dependencies through an InheritedWidget.
///
/// Supports two modes:
/// - standalone() - builds dependencies for standalone use
/// - embedded() - builds dependencies for embedding inside another app
final class ProfileFeatureDependenciesScope extends InheritedWidget {
  const ProfileFeatureDependenciesScope._({
    required this.dependencies,
    required super.child,
    super.key,
  });

  /// Constructor for standalone mode - the feature runs on its own.
  factory ProfileFeatureDependenciesScope.standalone({
    required Widget child,
    Key? key,
  }) {
    final dependencies = ProfileFeatureDependencies.standalone();

    return ProfileFeatureDependenciesScope._(
      dependencies: dependencies,
      child: child,
      key: key,
    );
  }

  /// Constructor for embedded mode - the feature is hosted in another app.
  factory ProfileFeatureDependenciesScope.embedded({
    required NavigationController navigationController,
    required Widget child,
    Key? key,
  }) {
    final dependencies = ProfileFeatureDependencies.embedded(
      navigationController: navigationController,
    );

    return ProfileFeatureDependenciesScope._(
      dependencies: dependencies,
      child: child,
      key: key,
    );
  }

  /// Constructor accepting ready-made dependencies (for backwards compatibility).
  const ProfileFeatureDependenciesScope({
    required this.dependencies,
    required super.child,
    super.key,
  }) : super();

  /// Resolves ProfileFeatureDependencies from the given context.
  static ProfileFeatureDependencies of(
    BuildContext context, {
    bool listen = true,
  }) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<
            ProfileFeatureDependenciesScope>()
        : context
            .getInheritedWidgetOfExactType<ProfileFeatureDependenciesScope>();

    if (scope == null) {
      throw FlutterError(
        'ProfileFeatureDependenciesScope not found in context. '
        'Make sure to wrap your app with ProfileFeatureDependenciesScope.',
      );
    }

    return scope.dependencies;
  }

  final ProfileFeatureDependencies dependencies;

  @override
  bool updateShouldNotify(
    covariant ProfileFeatureDependenciesScope oldWidget,
  ) =>
      dependencies != oldWidget.dependencies;
}
