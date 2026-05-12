import 'package:flutter/foundation.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../app_routes.dart';

/// Second handler for `/order/*` path to demonstrate FIFO vs LIFO strategy.
///
/// This handler competes with [OrderV1DeeplinkHandler] for the same deeplink path.
/// - With FIFO strategy: [OrderV1DeeplinkHandler] (registered first) wins
/// - With LIFO strategy: [OrderV2DeeplinkHandler] (registered last) wins
class OrderV2DeeplinkHandler implements DeeplinkHandler {
  const OrderV2DeeplinkHandler();

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'order') {
      if (uri.pathSegments.length > 1) {
        final orderId = uri.pathSegments[1];
        debugPrint('[OrderV2Handler] Handling order: $orderId');
        final newState = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(route: AppRoutes.home),
            RouteNode.fromRoute(
              route: AppRoutes.orderDetailsV2,
              arguments: {'orderId': orderId},
            ),
          ],
        );
        return DeeplinkHandlerResult.navigate(newState);
      }
    }

    return null;
  }
}
