import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'profile_skeleton_page.dart';

/// Routes for the driver-profile section.
abstract class ProfileRoutes {
  /// Profile home page - driver overview.
  static const home = YxRoute(id: 'profile-home');

  /// Driver profile - view and edit driver details.
  static const driverProfile = YxRoute(id: 'profile-driver');

  /// Trips history - list of completed orders.
  static const tripsHistory = YxRoute(id: 'profile-trips-history');

  /// Statistics - earnings and ratings analytics.
  static const statistics = YxRoute(id: 'profile-statistics');

  /// Settings - app configuration.
  static const settings = YxRoute(id: 'profile-settings');

  /// Documents - upload and manage documents.
  static const documents = YxRoute(id: 'profile-documents');
}

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

/// Navigation schema for the driver-profile section.
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
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const ProfileSkeletonPage(
              title: 'My profile',
              nextRoutes: [
                ProfileRoutes.driverProfile,
                ProfileRoutes.tripsHistory,
                ProfileRoutes.statistics,
                ProfileRoutes.settings,
                ProfileRoutes.documents,
              ],
            ),
          ),
        ),
        driverProfileRouteDeclaration,
        tripsHistoryRouteDeclaration,
        statisticsRouteDeclaration,
        settingsRouteDeclaration,
        documentsRouteDeclaration,
      ];

  ProfileNavigationSchema();

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([ProfileRoutes.home.toNode()]);
}
