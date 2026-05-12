import 'package:yx_navigation/yx_navigation.dart';

import '../app_routes.dart';

class PromoDeeplinkHandler implements DeeplinkHandler {
  const PromoDeeplinkHandler();

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    if (uri.path == '/promo') {
      final code = uri.queryParameters['code'] ?? 'UNKNOWN';
      final mutableState = currentState.toMutable();
      mutableState.add(
        RouteNode.fromRoute(
          route: AppRoutes.promo,
          arguments: {'code': code},
        ),
      );
      return DeeplinkHandlerResult.navigate(mutableState);
    }
    return null;
  }
}
