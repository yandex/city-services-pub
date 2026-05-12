import 'package:yx_navigation/yx_navigation.dart';

import '../app_routes.dart';
import 'profile_routes.dart';

/// First handler for /profile/settings (V1).
///
/// Competes with [ProfileSettingsV2DeeplinkHandler] at the
/// [ProfileNavigationSchema] level. The winner depends on the strategy:
/// - FIFO (default): V1 wins (registered first) → blue page
/// - LIFO: V2 wins (registered last) → green page
class ProfileSettingsV1DeeplinkHandler implements DeeplinkHandler {
  const ProfileSettingsV1DeeplinkHandler();

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    if (uri.pathSegments.length < 2) return null;
    if (uri.pathSegments[0] != 'profile') return null;
    if (uri.pathSegments[1] != 'settings') return null;

    final newState = RouteNode.fromRoute(
      route: const YxRoute(id: 'root'),
      children: [
        RouteNode.fromRoute(route: AppRoutes.home),
        RouteNode.fromRoute(
          route: AppRoutes.profile,
          children: [
            ProfileRoutes.home.toNode(),
            RouteNode.fromRoute(
              route: ProfileRoutes.settings,
              arguments: {'handler': 'ProfileSettingsV1Handler (V1)'},
            ),
          ],
        ),
      ],
    );

    return DeeplinkHandlerResult.navigate(newState);
  }
}
