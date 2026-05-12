import 'package:yx_navigation/yx_navigation.dart';

import '../app_routes.dart';
import 'profile_routes.dart';

/// Second handler for /profile/settings — competes with [ProfileSettingsV1DeeplinkHandler].
///
/// Demonstrates FIFO vs LIFO at the [ProfileNavigationSchema] level:
/// - FIFO: [ProfileSettingsV1DeeplinkHandler] (registered first) wins → blue page
/// - LIFO: this handler (registered last) wins → green page
class ProfileSettingsV2DeeplinkHandler implements DeeplinkHandler {
  const ProfileSettingsV2DeeplinkHandler();

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
              arguments: {'handler': 'ProfileSettingsV2Handler (V2)'},
            ),
          ],
        ),
      ],
    );

    return DeeplinkHandlerResult.navigate(newState);
  }
}
