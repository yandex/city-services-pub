import 'package:flutter/foundation.dart';
import 'package:yx_navigation/yx_navigation.dart';

class AnalyticsDeeplinkHandler implements DeeplinkHandler {
  const AnalyticsDeeplinkHandler();

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    if (uri.path == '/track') {
      final event = uri.queryParameters['event'];
      if (event != null) {
        debugPrint('[Analytics] Tracked event: $event');
        return const DeeplinkHandlerResult.handled();
      }
    }
    return null;
  }
}
