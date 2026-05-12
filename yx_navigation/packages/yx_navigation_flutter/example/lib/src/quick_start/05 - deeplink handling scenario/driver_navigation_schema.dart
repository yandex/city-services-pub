import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'driver_routes.dart';
import 'driver_skeleton_page.dart';

/// Home page declaration
final homeRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.home,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => DriverSkeletonPage(
      title: 'Home',
      icon: Icons.home,
      subtitle: 'Try deeplinks in the address bar',
      color: Colors.blue,
    ),
  ),
);

/// Order details page declaration
final orderDetailsRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.orderDetails,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => DriverSkeletonPage(
      title: 'Order Details',
      icon: Icons.article,
      subtitle: 'Opened via deeplink /order_details?id=...',
      color: Colors.orange,
    ),
  ),
);

/// Profile page declaration
final profileRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.profile,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => DriverSkeletonPage(
      title: 'Profile',
      icon: Icons.person,
      color: Colors.green,
    ),
  ),
);

/// Settings page declaration
final settingsRouteDeclaration = RouteDeclaration.routeBuilder(
  route: DriverRoutes.settings,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => DriverSkeletonPage(
      title: 'Settings',
      icon: Icons.settings,
      subtitle: 'Opened via deeplink /settings (push)',
      color: Colors.purple,
    ),
  ),
);

/// Navigation schema for deeplink handling demonstration
///
/// Structure:
/// Root
/// - Home (home)
/// - Order Details (orderDetails) - opened via deeplink /order_details?id=...
/// - Profile (profile)
/// - Settings (settings) - opened via deeplink /settings
///
base class DriverNavigationSchema extends RouterSchema {
  DriverNavigationSchema({
    Iterable<DeeplinkHandler> deeplinkHandlers = const [],
  }) : _deeplinkHandlers = deeplinkHandlers;

  final Iterable<DeeplinkHandler> _deeplinkHandlers;

  @override
  Iterable<DeeplinkHandler> get deeplinkHandlers => _deeplinkHandlers;

  @override
  List<RouteDeclaration> get declarations => [
        homeRouteDeclaration,
        orderDetailsRouteDeclaration,
        profileRouteDeclaration,
        settingsRouteDeclaration,
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([RouteNode.fromRoute(route: DriverRoutes.home)]);
}
