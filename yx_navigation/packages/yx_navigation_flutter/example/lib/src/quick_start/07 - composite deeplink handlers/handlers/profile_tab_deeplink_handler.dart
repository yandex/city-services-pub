import 'package:yx_navigation/yx_navigation.dart';

import '../app_routes.dart';
import '../nested/profile_routes.dart';

/// Deeplink handler for navigating to the main profile page.
///
/// Handles only the base /profile path.
/// Nested paths (/profile/settings, /profile/documents) are handled
/// by ProfileDeeplinkHandler from the nested ProfileNavigationSchema.
///
/// Builds the full navigation state including parent routes
/// so that back navigation works correctly.
class ProfileTabDeeplinkHandler implements DeeplinkHandler {
  const ProfileTabDeeplinkHandler();

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    if (uri.pathSegments.isEmpty || uri.pathSegments.first != 'profile') {
      return null;
    }

    // Handle only the base /profile path
    // Nested paths are handled by ProfileDeeplinkHandler
    if (uri.pathSegments.length > 1) {
      return null;
    }

    // Build full state: root -> home, profile(nested state)
    final newState = RouteNode.fromRoute(
      route: const YxRoute(id: 'root'),
      children: [
        RouteNode.fromRoute(route: AppRoutes.home),
        RouteNode.fromRoute(
          route: AppRoutes.profile,
          children: [ProfileRoutes.home.toNode()],
        ),
      ],
    );

    return DeeplinkHandlerResult.navigate(newState);
  }
}
