import 'package:yx_navigation/yx_navigation.dart';

import '../app_routes.dart';
import 'profile_routes.dart';

/// Deeplink handler for the nested profile schema.
///
/// Handles only /profile/documents.
/// The /profile/settings paths are handled by specialized handlers
/// (ProfileSettingsV1DeeplinkHandler / ProfileSettingsV2DeeplinkHandler),
/// registered in [ProfileNavigationSchema]. This way the strategy
/// (FIFO/LIFO) fairly determines which Settings handler wins,
/// without competition from this generic handler.
class ProfileDeeplinkHandler implements DeeplinkHandler {
  const ProfileDeeplinkHandler();

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    if (uri.pathSegments.isEmpty || uri.pathSegments.first != 'profile') {
      return null;
    }

    if (uri.pathSegments.length < 2 || uri.pathSegments[1] != 'documents') {
      return null;
    }

    final newState = RouteNode.fromRoute(
      route: const YxRoute(id: 'root'),
      children: [
        RouteNode.fromRoute(route: AppRoutes.home),
        RouteNode.fromRoute(
          route: AppRoutes.profile,
          children: [
            ProfileRoutes.home.toNode(),
            RouteNode.fromRoute(
              route: ProfileRoutes.documents,
              arguments: {'handler': 'ProfileHandler (generic)'},
            ),
          ],
        ),
      ],
    );

    return DeeplinkHandlerResult.navigate(newState);
  }
}
