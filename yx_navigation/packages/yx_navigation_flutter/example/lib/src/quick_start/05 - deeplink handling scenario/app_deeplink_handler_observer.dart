import 'package:flutter/foundation.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// {@template app_deeplink_handler_observer}
/// Example deeplink handling observer.
///
/// Logs all deeplink handling events:
/// - [onDeeplinkReceived] — new deeplink received
/// - [onDeeplinkNavigate] — deeplink handled with navigation
/// - [onDeeplinkHandled] — deeplink handled without navigation
/// - [onDeeplinkSkipped] — deeplink not recognized and skipped
/// - [onDeeplinkError] — error while handling deeplink
/// {@endtemplate}
class AppDeeplinkHandlerObserver extends DeeplinkHandlerObserver {
  /// {@macro app_deeplink_handler_observer}
  const AppDeeplinkHandlerObserver();

  @override
  void onDeeplinkReceived({
    required Uri uri,
    required RouteNode currentState,
  }) {
    super.onDeeplinkReceived(uri: uri, currentState: currentState);
    debugPrint(
      '[DeeplinkObserver] 📥 Received deeplink: $uri\n'
      '  Current state: ${_formatRouteNode(currentState)}',
    );
  }

  @override
  void onDeeplinkNavigate({
    required Uri uri,
    required RouteNode currentState,
    required RouteNode targetState,
  }) {
    super.onDeeplinkNavigate(
      uri: uri,
      currentState: currentState,
      targetState: targetState,
    );
    debugPrint(
      '[DeeplinkObserver] 🚀 Navigate from deeplink: $uri\n'
      '  From: ${_formatRouteNode(currentState)}\n'
      '  To: ${_formatRouteNode(targetState)}',
    );
  }

  @override
  void onDeeplinkHandled({
    required Uri uri,
    required RouteNode currentState,
  }) {
    super.onDeeplinkHandled(uri: uri, currentState: currentState);
    debugPrint(
      '[DeeplinkObserver] ✅ Handled deeplink (no navigation): $uri',
    );
  }

  @override
  void onDeeplinkSkipped({
    required Uri uri,
    required RouteNode currentState,
  }) {
    super.onDeeplinkSkipped(uri: uri, currentState: currentState);
    debugPrint(
      '[DeeplinkObserver] ⏭️ Skipped unrecognized deeplink: $uri',
    );
  }

  @override
  void onDeeplinkError({
    required Uri uri,
    required RouteNode currentState,
    required Object error,
    required StackTrace stackTrace,
  }) {
    super.onDeeplinkError(
      uri: uri,
      currentState: currentState,
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint(
      '[DeeplinkObserver] ❌ Error handling deeplink: $uri\n'
      '  Error: $error\n'
      '  Stack trace: $stackTrace',
    );
  }

  String _formatRouteNode(RouteNode node) {
    final routes = <String>[];
    void collect(RouteNode n) {
      routes.add(n.route.id);
      for (final child in n.children) {
        collect(child);
      }
    }

    collect(node);
    return routes.join(' → ');
  }
}
