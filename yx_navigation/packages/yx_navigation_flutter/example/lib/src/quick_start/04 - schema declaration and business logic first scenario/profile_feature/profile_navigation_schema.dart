import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

// Profile routes live inside the feature.
import 'profile_routes.dart';

// The feature's adapted ProfileSkeletonPage.
import 'profile_skeleton_page.dart';

/// Profile home page declaration.
final homeRouteDeclaration = RouteDeclaration.routeBuilder(
  route: ProfileRoutes.home,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => ProfileSkeletonPage(
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
);

/// Driver profile page declaration.
final driverProfileRouteDeclaration = RouteDeclaration.routeBuilder(
  route: ProfileRoutes.driverProfile,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => ProfileSkeletonPage(
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
    ),
  ),
);

/// Statistics page declaration.
final statisticsRouteDeclaration = RouteDeclaration.routeBuilder(
  route: ProfileRoutes.statistics,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => ProfileSkeletonPage(
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

/// Adapted profile navigation schema for scenario 04.
///
/// Uses ProfileSkeletonPage adapted to work with
/// ProfileFeatureNavigationController via Dependencies.
///
/// Supports initial-state configuration through route arguments:
/// - 'home' (default) - opens the profile home
/// - 'driverProfile' - opens the driver profile
/// - 'settings' - opens settings
/// - and other available pages
base class ProfileNavigationSchema extends RouterSchema {
  @override
  List<RouteDeclaration> get declarations => [
        homeRouteDeclaration,
        driverProfileRouteDeclaration,
        tripsHistoryRouteDeclaration,
        statisticsRouteDeclaration,
        settingsRouteDeclaration,
        documentsRouteDeclaration,
      ];

  ProfileNavigationSchema();

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) {
    // Read parent-node arguments to pick the initial state.
    final arguments = node.arguments;
    final initialPage = arguments['initialPage'] ?? 'home';

    // Pick the initial route based on the argument.
    final initialRoute = _getInitialRoute(initialPage);
    final initialNodes = _buildInitialNodes(initialPage, initialRoute);

    node.setChildren(initialNodes);
    return node;
  }

  /// Picks the initial route from the given parameter.
  static YxRoute _getInitialRoute(String initialPage) {
    switch (initialPage) {
      case 'driverProfile':
        return ProfileRoutes.driverProfile;
      case 'tripsHistory':
        return ProfileRoutes.tripsHistory;
      case 'statistics':
        return ProfileRoutes.statistics;
      case 'settings':
        return ProfileRoutes.settings;
      case 'documents':
        return ProfileRoutes.documents;
      case 'home':
      default:
        return ProfileRoutes.home;
    }
  }

  /// Builds the initial navigation nodes.
  /// When the requested page is not home we build a home -> target stack
  /// so that pressing back works correctly.
  static List<RouteNode> _buildInitialNodes(
    String initialPage,
    YxRoute initialRoute,
  ) {
    if (initialPage == 'home') {
      // Simple case - only the home page.
      return [ProfileRoutes.home.toNode()];
    } else {
      // Compound case - home + target page stack.
      // This keeps the back button working as expected.
      return [
        ProfileRoutes.home.toNode(),
        initialRoute.toNode(),
      ];
    }
  }
}
