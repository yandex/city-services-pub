import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'profile_pages.dart';
import 'profile_routes.dart';

/// Navigation schema for the driver-profile section.
class ProfileSchema extends RouterSchema {
  ProfileSchema();

  @override
  List<RouteDeclaration> get declarations => [
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.home,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const ProfileHomePage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.driverProfile,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const DriverProfilePage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.tripsHistory,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const TripsHistoryPage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.statistics,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const StatisticsPage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.settings,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const ProfileSettingsPage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.documents,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const DocumentsPage(),
          ),
        ),

        // Demo route for the empty state.
        // An outlet with no children creates an empty navigator.
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.demoEmpty,
          routeBuilder: RouteBuilder.outlet(),
        ),
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([ProfileRoutes.home.toNode()]);
}
