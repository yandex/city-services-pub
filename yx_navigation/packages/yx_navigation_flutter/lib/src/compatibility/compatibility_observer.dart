import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// {@template compatibility_observer}
/// Observer for monitoring Navigator 1.0 compatibility layer events.
///
/// Provides hooks for tracking pageless routes created through
/// Navigator 1.0 API methods like [Navigator.push], [showDialog], etc.
///
/// Similar to [NavigatorObserver] but specifically for compatibility layer.
/// {@endtemplate}
///
/// ## Use Cases
///
/// - **Analytics**: Track usage of legacy Navigator 1.0 APIs
/// - **Migration monitoring**: Measure progress of migration to declarative navigation
/// - **Debugging**: Log pageless route lifecycle events
///
/// ## Example
///
/// ```dart
/// class MyCompatibilityObserver extends CompatibilityObserver {
///   @override
///   bool willPushPagelessRoute(
///     Route<dynamic> route,
///     String routeId,
///   ) {
///     // Validate or log before processing
///     print('Will push pageless route: ${route.runtimeType}');
///     return true; // Allow processing
///   }
///
///   @override
///   void didCreatePagelessRoute(
///     Route<dynamic> route,
///     String routeId,
///     String routeType,
///     RouteNode routeNode,
///   ) {
///     print('Pageless route created: $routeType ($routeId)');
///     analytics.trackLegacyRoute(routeType);
///   }
/// }
///
/// // Register in NavigatorCompatibilityOverrides:
/// NavigationConfigProvider(
///   navigatorOverrides: NavigatorCompatibilityOverrides(
///     observer: MyCompatibilityObserver(),
///   ),
///   child: MaterialApp.router(routerConfig: config),
/// )
/// ```
///
/// See also:
///
/// * [NavigatorCompatibilityOverrides], which uses this observer
/// * [NavigatorObserver], Flutter's standard navigation observer
abstract class CompatibilityObserver {
  /// Called BEFORE a pageless route is processed.
  ///
  /// This is invoked before the route is converted to page-based navigation,
  /// allowing the observer to inspect, validate, or block the route.
  ///
  /// Return `false` to prevent processing (route will fall back to native Navigator).
  /// Return `true` to allow processing (default).
  ///
  /// ## Parameters
  ///
  /// * [routeNodeReadable] - The [RouteNodeReadable] instance that provides access to the parent node of the created route node
  /// * [route] - The original [Route] instance from Navigator 1.0 API
  /// * [routeId] - Generated unique ID for this route in YxNavigation
  ///
  /// ## Use Cases
  ///
  /// - **Validation**: Block certain route types from processing
  /// - **Logging**: Track route creation attempts before conversion
  /// - **Debugging**: Inspect routes before they enter compatibility layer
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// bool willPushPagelessRoute({
  ///   required RouteNodeReadable routeNodeReadable,
  ///   required Route<dynamic> route,
  ///   required String routeId,
  /// }) {
  ///   // Block unnamed routes
  ///   if (route.settings.name == null) {
  ///     debugPrint('Blocking unnamed route: ${route.runtimeType}');
  ///     return false;
  ///   }
  ///
  ///   // Log before processing
  ///   debugPrint('Will process: ${route.runtimeType} ($routeId)');
  ///   return true;
  /// }
  /// ```
  bool willPushPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
  }) =>
      true;

  /// Called when a pageless route is successfully created and converted.
  ///
  /// This is invoked after the route has been converted to page-based navigation
  /// and wrapped in a [RouteNode].
  ///
  /// ## Parameters
  ///
  /// * [routeNodeReadable] - The [RouteNodeReadable] instance that provides access to the parent node of the created route node
  /// * [route] - The original [Route] instance created by Navigator 1.0 API
  /// * [routeId] - Generated unique ID for this route in YxNavigation
  /// * [routeType] - Runtime type name of the route (e.g., "MaterialPageRoute")
  /// * [routeNode] - The immutable [RouteNode] created for this route
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void didCreatePagelessRoute({
  ///   required RouteNodeReadable routeNodeReadable,
  ///   required Route<dynamic> route,
  ///   required String routeId,
  ///   required String routeType,
  ///   required RouteNode routeNode,
  /// }) {
  ///   // Track in analytics
  ///   analytics.trackEvent(
  ///     'legacy_route_created',
  ///     properties: {
  ///       'route_id': routeId,
  ///       'route_type': routeType,
  ///       'route_name': route.settings.name,
  ///       'has_children': routeNode.children.isNotEmpty,
  ///     },
  ///   );
  ///
  ///   // Log for debugging
  ///   if (kDebugMode) {
  ///     debugPrint('Pageless route: $routeType at ${route.settings.name}');
  ///   }
  /// }
  /// ```
  void didCreatePagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
    required String routeType,
    required RouteNode routeNode,
  }) {}

  /// Called when a pageless route creation attempt fails.
  ///
  /// This occurs when:
  /// - Route type is not supported by compatibility layer (e.g., PopupMenuRoute)
  /// - Route cannot be converted to page-based navigation
  /// - Observer blocked processing via [willPushPagelessRoute] returning false
  ///
  /// The route will fall back to native Navigator behavior (pageless mode).
  ///
  /// **Note:** This is called from `YxNavigator` after catching [UnsupportedRouteException],
  /// just before falling back to native Navigator.
  ///
  /// ## Parameters
  ///
  /// * [routeNodeReadable] - The [RouteNodeReadable] instance that provides access to the parent node of the created route node
  /// * [route] - The route that failed to be converted
  /// * [error] - The [UnsupportedRouteException] that occurred
  /// * [routeNode] - Always `null` - route was never successfully created
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void didFailPagelessRoute({
  ///   required RouteNodeReadable routeNodeReadable,
  ///   required Route<dynamic> route,
  ///   required Object error,
  ///   required RouteNode? routeNode,
  /// }) {
  ///   // Log unsupported routes
  ///   logger.warning(
  ///     'Route fallback to native Navigator: ${route.runtimeType}',
  ///     error: error,
  ///   );
  ///
  ///   // Track in analytics
  ///   analytics.trackEvent('unsupported_route', {
  ///     'route_type': route.runtimeType.toString(),
  ///     'route_name': route.settings.name,
  ///   });
  /// }
  /// ```
  void didFailPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required Object error,
    required RouteNode? routeNode,
  }) {}
}
