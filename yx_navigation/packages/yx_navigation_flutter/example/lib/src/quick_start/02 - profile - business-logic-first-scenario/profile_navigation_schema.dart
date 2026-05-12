import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'profile_home_page.dart';
import 'profile_routes.dart';
import 'profile_skeleton_page.dart';

/// Driver profile page declaration.
final driverProfileRouteDeclaration = RouteDeclaration.routeBuilder(
  route: ProfileRoutes.driverProfile,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => const ProfileSkeletonPage(
      title: 'Driver profile',
      nextRoutes: [ProfileRoutes.settings],
    ),
  ),
);

/// Trips history page declaration.
final tripsHistoryRouteDeclaration = RouteDeclaration.routeBuilder(
  route: ProfileRoutes.tripsHistory,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => const ProfileSkeletonPage(
      title: 'Trips history',
      nextRoutes: [ProfileRoutes.statistics],
    ),
  ),
);

/// Statistics page declaration.
final statisticsRouteDeclaration = RouteDeclaration.routeBuilder(
  route: ProfileRoutes.statistics,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => const ProfileSkeletonPage(
      title: 'Statistics',
      nextRoutes: [ProfileRoutes.tripsHistory],
    ),
  ),
);

/// Settings page declaration.
final settingsRouteDeclaration = RouteDeclaration.routeBuilder(
  route: ProfileRoutes.settings,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => const ProfileSkeletonPage(
      title: 'Settings',
      nextRoutes: [ProfileRoutes.documents],
    ),
  ),
);

/// Documents page declaration.
final documentsRouteDeclaration = RouteDeclaration.routeBuilder(
  route: ProfileRoutes.documents,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => const ProfileSkeletonPage(
      title: 'Documents',
    ),
  ),
);

/// Navigation schema for the driver profile (business-logic-first variant).
///
/// Differences from the Flutter-first variant:
/// - The initial state is not configured through initialNodeBuilder
/// - The initial state is owned by ProfileNavigationInteractor
/// - stateManager is passed in when build() is called
///
/// Structure:
/// Profile home
///   Driver profile (driverProfile)
///   Trips history (tripsHistory)
///   Statistics (statistics)
///   Settings (settings)
///   Documents (documents)
base class ProfileNavigationSchema extends RouterSchema {
  @override
  List<RouteDeclaration> get declarations => [
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.home,
          routeBuilder: RouteBuilder.outlet(
            outletBuilder: (context, state, outlet) => ProfileHomePage(
              title: 'My profile',
              outlet: outlet,
            ),
          ),
          declarations: [
            driverProfileRouteDeclaration,
            tripsHistoryRouteDeclaration,
            statisticsRouteDeclaration,
            settingsRouteDeclaration,
            documentsRouteDeclaration,
          ],
        ),
      ];

  ProfileNavigationSchema();

  // In the business-logic-first variant the initial state lives in
  // ProfileNavigationInteractor; we receive it via the injected
  // state manager.
  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node; // Empty builder - the state is already set.
}
