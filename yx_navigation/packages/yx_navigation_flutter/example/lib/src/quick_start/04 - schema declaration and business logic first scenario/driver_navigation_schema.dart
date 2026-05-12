import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

// Adapted profile schema for this example.
import 'driver_app_dependencies.dart';
import 'profile_feature/profile_feature_dependencies.dart'; // Only for ProfileFeatureDependenciesScope
import 'profile_feature/profile_navigation_schema.dart';

import 'driver_routes.dart';
import 'driver_skeleton_page.dart';

/// Sign-in page declaration.
final loginRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.login,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => DriverSkeletonPage(
      title: 'Sign in',
      icon: Icons.login,
      description: 'Driver sign-in',
      nextRoutes: const [DriverRoutes.home],
    ),
  ),
);

/// Home page declaration.
final homeRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.home,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => DriverSkeletonPage(
      title: 'Home dashboard',
      icon: Icons.home,
      description: 'Driver dashboard',
      nextRoutes: const [
        DriverRoutes.orders,
        DriverRoutes.messages,
        DriverRoutes.profile,
      ],
    ),
  ),
);

/// Orders page declaration.
final ordersRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.orders,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => DriverSkeletonPage(
      title: 'Orders',
      icon: Icons.work,
      description: 'List of active and available orders',
      nextRoutes: const [DriverRoutes.home],
    ),
  ),
);

/// Messages page declaration.
final messagesRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.messages,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => DriverSkeletonPage(
      title: 'Messages',
      icon: Icons.message,
      description: 'Support chat and system notifications',
      nextRoutes: const [DriverRoutes.profile],
    ),
  ),
);

/// Key feature: RouteDeclaration.scheme with isolated features.
///
/// Unlike scenario 03 (Flutter-first), here:
/// - The host app is driven through DriverNavigationInteractor
/// - The nested profile feature is fully isolated
/// - The feature builds its own dependencies inside outletBuilder
/// - Only a NavigationController is passed to access shared state
/// - Combination of Schema Declaration + Business Logic First
final profileSchemaDeclaration = RouteDeclaration.scheme(
  route: DriverRoutes.profile,
  schema: ProfileNavigationSchema(),
  outletBuilder: (context, state, outlet) {
    // Grab the NavigationController from the host-app dependencies.
    final profileNavigationController =
        DriverAppDependenciesScope.of(context).profileNavigationController;

    // Use the smart constructor - the feature builds its own dependencies.
    // Full isolation: the host app does not know about ProfileFeatureDependencies.
    return ProfileFeatureDependenciesScope.embedded(
      navigationController: profileNavigationController,
      child: outlet,
    );
  },
);

/// Navigation schema for the driver app (scenario 04).
///
/// Shows a combination of approaches:
/// - Schema Declaration - used to mount nested features
/// - Business Logic First - navigation is driven from business logic
///
/// Navigation structure:
/// - Login (entry point) - owned by DriverNavigationInteractor
/// - Home (dashboard) - owned by DriverNavigationInteractor
///   - Orders - owned by DriverNavigationInteractor
///   - Messages - owned by DriverNavigationInteractor
///   - Profile (NESTED SCHEMA)
///     - Profile Home - owned by ProfileNavigationInteractor (isolated)
///     - Driver Profile - owned by ProfileNavigationInteractor (isolated)
///     - Trips History - owned by ProfileNavigationInteractor (isolated)
///     - Statistics - owned by ProfileNavigationInteractor (isolated)
///     - Settings - owned by ProfileNavigationInteractor (isolated)
///     - Documents - owned by ProfileNavigationInteractor (isolated)
///
/// Important difference from scenario 03:
/// - No initialNodeBuilder - the initial state is set in DriverNavigationInteractor
/// - The schema is used with an external RouteNodeStateManager
/// - Navigation is driven from business logic, not the UI
base class DriverNavigationSchema extends RouterSchema {
  @override
  List<RouteDeclaration> get declarations => [
        // Host-app routes.
        loginRouteDeclaration,
        homeRouteDeclaration,
        ordersRouteDeclaration,
        messagesRouteDeclaration,

        // Mount the nested schema.
        // ProfileNavigationSchema is mounted as an isolated module.
        // It builds its own dependencies inside outletBuilder.
        profileSchemaDeclaration,
      ];

  /// Unlike scenario 03, here we use an empty initialNodeBuilder.
  /// The initial navigation state is established by DriverNavigationInteractor
  /// when RouteNodeStateManager is created.
  DriverNavigationSchema();

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node; // Empty builder - the state is set in DriverNavigationInteractor.
}
