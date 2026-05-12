import 'package:yx_navigation/yx_navigation.dart';

import '../app_routes.dart';

class OrderV1DeeplinkHandler implements DeeplinkHandler {
  const OrderV1DeeplinkHandler();

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'order') {
      if (uri.pathSegments.length > 1) {
        final orderId = uri.pathSegments[1];
        final newState = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(route: AppRoutes.home),
            RouteNode.fromRoute(
              route: AppRoutes.orderDetails,
              arguments: {'orderId': orderId},
            ),
          ],
        );
        return DeeplinkHandlerResult.navigate(newState);
      }
    }

    if (uri.path == '/orders') {
      final newState = RouteNode.fromRoute(
        route: const YxRoute(id: 'root'),
        children: [
          RouteNode.fromRoute(route: AppRoutes.home),
          RouteNode.fromRoute(route: AppRoutes.ordersList),
        ],
      );
      return DeeplinkHandlerResult.navigate(newState);
    }

    return null;
  }
}
