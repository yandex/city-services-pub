import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'routes.dart';

/// Navigation schema for the Compatibility Mode demo.
///
/// Demonstrates:
/// - RouteDeclaration usage (declarative navigation)
/// - Interop with Navigator 1.0 API (imperative navigation)
/// - Mixing page-based and pageless routes
class CompatibilityNavigationSchema extends RouterSchema {
  CompatibilityNavigationSchema();

  @override
  List<RouteDeclaration> get declarations => [
        // Home page showcasing every compatibility feature.
        RouteDeclaration.routeBuilder(
          route: CompatibilityRoutes.home,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const CompatibilityHomePage(),
          ),
        ),

        // Profile page used to demonstrate a Navigator 1.0 push.
        RouteDeclaration.routeBuilder(
          route: CompatibilityRoutes.profile,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const CompatibilityProfilePage(),
          ),
        ),
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([CompatibilityRoutes.home.toNode()]);
}
