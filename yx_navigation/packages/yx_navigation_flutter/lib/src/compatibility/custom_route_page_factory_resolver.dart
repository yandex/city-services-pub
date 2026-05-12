import 'dart:async';

import 'package:flutter/widgets.dart';

/// {@template custom_route_page_factory_resolver}
/// Interface for custom handling of specific [Route] types that are not
/// supported out of the box by [NavigatorCompatibilityOverrides].
///
/// This allows applications to integrate custom [Route] implementations
/// from third-party libraries or legacy code into YxNavigation's
/// declarative navigation system.
///
/// ## Purpose
///
/// [NavigatorCompatibilityOverrides] provides built-in support for standard
/// Flutter route types:
/// - [MaterialPageRoute]
/// - [CupertinoPageRoute]
/// - [ModalBottomSheetRoute]
/// - Any [ModalRoute] via `modalRouteProxy`
///
/// However, real-world applications may use custom [Route] classes with:
/// - Custom transition animations
/// - Specific route parameters (e.g., for analytics)
/// - Third-party library route implementations
///
/// [CustomRoutePageFactoryResolver] enables handling of these custom types.
///
/// ## Implementation
///
/// To create a custom resolver:
///
/// 1. Implement [hasResolverFor] to identify your custom [Route] types
/// 2. Implement [resolvePage] to create appropriate [Page] objects
///
/// Example resolver for a custom transition route:
///
/// ```dart
/// class MyCustomResolver implements CustomRoutePageFactoryResolver {
///   @override
///   bool hasResolverFor<T>(Route<T> route) {
///     return route is MyCustomTransitionRoute;
///   }
///
///   @override
///   Page<Object?> resolvePage<T>({
///     required Completer<T?> routeCompleter,
///     required Route<T> route,
///     required LocalKey key,
///   }) {
///     final customRoute = route as MyCustomTransitionRoute<T>;
///     return MyCustomPage<T>(
///       key: key,
///       name: route.settings.name,
///       arguments: route.settings.arguments,
///       routeCompleter: routeCompleter,
///       transitionDuration: customRoute.transitionDuration,
///       child: Builder(
///         builder: (context) => customRoute.buildPage(
///           context,
///           customRoute.animation ?? kAlwaysDismissedAnimation,
///           customRoute.secondaryAnimation ?? kAlwaysDismissedAnimation,
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Registration
///
/// Register your resolver with [NavigatorCompatibilityOverrides]:
///
/// ```dart
/// NavigationConfigProvider(
///   navigatorOverrides: NavigatorCompatibilityOverrides(
///     customRoutePageFactoryResolver: MyCustomResolver(),
///   ),
///   child: MaterialApp.router(routerConfig: config),
/// )
/// ```
///
/// ## Resolution Priority
///
/// Custom resolvers are checked **first**, before built-in route types.
/// This allows overriding default handling if needed.
///
/// See also:
///
/// * [NavigatorCompatibilityOverrides], which uses this resolver
/// * [Route], the base class for all navigation routes
/// * [Page], the declarative representation of routes
/// {@endtemplate}
abstract class CustomRoutePageFactoryResolver {
  /// {@macro custom_route_page_factory_resolver}
  const CustomRoutePageFactoryResolver();

  /// Determines whether this resolver can handle the given [route].
  ///
  /// Return `true` if this resolver knows how to create a [Page] for
  /// the provided [route] type. Return `false` otherwise.
  ///
  /// This method is called for every route created via Navigator 1.0 API
  /// to determine if custom handling is needed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// bool hasResolverFor<T>(Route<T> route) {
  ///   // Handle specific route types
  ///   return route is MyCustomRoute || route is ThirdPartyRoute;
  /// }
  /// ```
  bool hasResolverFor<T>(Route<T> route);

  /// Creates a [Page] object for the given [route].
  ///
  /// This method is only called if [hasResolverFor] returns `true` for
  /// the [route].
  ///
  /// ## Parameters
  ///
  /// * [routeCompleter] - Completer to signal route completion and return
  ///   result. Must be completed when the route is popped.
  /// * [route] - The original [Route] created via Navigator 1.0 API
  /// * [key] - Unique key for the [Page] to maintain widget identity
  ///
  /// ## Returns
  ///
  /// A [Page] object that wraps the [route] and integrates it into
  /// YxNavigation's declarative state management.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// Page<Object?> resolvePage<T>({
  ///   required Completer<T?> routeCompleter,
  ///   required Route<T> route,
  ///   required LocalKey key,
  /// }) {
  ///   final customRoute = route as MyCustomRoute<T>;
  ///
  ///   return MyCustomPage<T>(
  ///     key: key,
  ///     name: route.settings.name,
  ///     routeCompleter: routeCompleter,
  ///     // Copy relevant properties from route
  ///     transitionDuration: customRoute.transitionDuration,
  ///     child: /* build widget from route */,
  ///   );
  /// }
  /// ```
  Page<Object?> resolvePage<T>({
    required Completer<T?> routeCompleter,
    required Route<T> route,
    required LocalKey key,
  });
}
