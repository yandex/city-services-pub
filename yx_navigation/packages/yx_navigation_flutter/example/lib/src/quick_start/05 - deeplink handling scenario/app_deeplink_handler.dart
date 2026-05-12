import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'driver_routes.dart';

/// {@template app_deeplink_handler}
/// Example deeplink handler demonstrating various scenarios:
///
/// 1. **navigate** — navigate to a specific screen
/// 2. **handled** — execute logic without navigation
/// 3. **push** — add a screen on top of the current state
/// 4. **error** — demonstrate error handling
/// {@endtemplate}
class AppDeeplinkHandler implements DeeplinkHandler {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  /// {@macro app_deeplink_handler}
  const AppDeeplinkHandler({required this.scaffoldMessengerKey});

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    // Scenario 1: Navigation (full stack replacement)
    // Example: /order_details?id=42
    if (_matchesPath(uri, 'order_details')) {
      final id = uri.queryParameters['id'] ?? 'No ID';

      final newState = RouteNode.fromRoute(
        route: const YxRoute(id: 'root'),
        children: [
          RouteNode.fromRoute(route: DriverRoutes.home),
          RouteNode.fromRoute(
            route: DriverRoutes.orderDetails,
            arguments: {'orderId': id},
          ),
        ],
      );

      return DeeplinkHandlerResult.navigate(newState);
    }

    // Scenario 2: Push a screen on top of the current state
    // Example: /settings
    if (_matchesPath(uri, 'settings')) {
      final mutableState = currentState.toMutable();
      mutableState.add(
        RouteNode.fromRoute(route: DriverRoutes.settings),
      );

      return DeeplinkHandlerResult.navigate(mutableState);
    }

    // Scenario 3: Side effect without navigation (Handled)
    // Example: /alert?msg=Hello
    if (_matchesPath(uri, 'alert')) {
      final msg = uri.queryParameters['msg'] ?? 'Deep link alert!';

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Deep Link Action: $msg'),
          backgroundColor: Colors.deepPurple,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      return const DeeplinkHandlerResult.handled();
    }

    // Scenario 4: Simulated error (for error handling demonstration)
    // Example: /crash
    if (_matchesPath(uri, 'crash')) {
      throw Exception('Simulated error in AppDeeplinkHandler!');
    }

    // Deeplink not handled — pass to the default parser
    return null;
  }

  /// Checks whether the URI matches the given path
  bool _matchesPath(Uri uri, String path) =>
      uri.path == '/$path' || uri.host == path;
}
