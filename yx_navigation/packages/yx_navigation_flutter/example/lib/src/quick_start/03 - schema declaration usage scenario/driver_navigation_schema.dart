import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

// Reuse the profile schema from scenario 01.
import '../01 - profile - flutter-first-scenario/profile_navigation_schema.dart';

import 'driver_routes.dart';
import 'driver_skeleton_page.dart';

/// Login page declaration.
final loginRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.login,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => const DriverSkeletonPage(
      title: 'Sign in',
      icon: Icons.login,
      description: 'Driver sign-in page',
      nextRoutes: [DriverRoutes.home],
    ),
  ),
);

/// Home page declaration.
final homeRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.home,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => const DriverSkeletonPage(
      title: 'Home dashboard',
      icon: Icons.home,
      description: 'Driver dashboard with an overview of recent activity',
      nextRoutes: [
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
    builder: (context, state) => const DriverSkeletonPage(
      title: 'Orders',
      icon: Icons.work,
      description: 'Available and active orders',
      nextRoutes: [DriverRoutes.messages],
    ),
  ),
);

/// Messages page declaration.
final messagesRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.messages,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => const DriverSkeletonPage(
      title: 'Messages',
      icon: Icons.message,
      description: 'Support chat and system notifications',
      nextRoutes: [DriverRoutes.profile],
    ),
  ),
);

/// Main showcase: RouteDeclaration.scheme.
///
/// Wires the full ProfileNavigationSchema from scenario 01 as a nested
/// schema for the profile route.
///
/// RouteDeclaration.scheme lets you:
/// - reuse existing navigation schemas
/// - build a modular architecture
/// - encapsulate complex navigation logic
/// - combine different features inside a single app
final profileSchemaDeclaration = RouteDeclaration.scheme(
  route: DriverRoutes.profile,
  schema: ProfileNavigationSchema(),
);

/// Navigation schema for the driver application.
///
/// Structure:
/// - Login (entry point)
/// - Home (dashboard)
///   - Orders
///   - Messages
///   - Profile (NESTED SCHEMA)
///     - Profile Home
///     - Driver Profile
///     - Trips History
///     - Statistics
///     - Settings
///     - Documents
base class DriverNavigationSchema extends RouterSchema {
  @override
  List<RouteDeclaration> get declarations => [
        // Top-level app routes.
        loginRouteDeclaration,
        homeRouteDeclaration,
        ordersRouteDeclaration,
        messagesRouteDeclaration,

        // Key feature: attach a nested schema.
        // Instead of a regular RouteDeclaration.routeBuilder we use
        // RouteDeclaration.scheme to mount an entire schema.
        profileSchemaDeclaration,
      ];

  DriverNavigationSchema();

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) => node
    ..setChildren(
      [
        DriverRoutes.login.toNode(),
        DriverRoutes.home.toNode(),
      ],
    );
}
