import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'navigator_compatibility_overrides.dart';

/// {@template route_node_compatibility_extension}
/// Extension on [RouteNode] that provides compatibility layer utilities
/// for distinguishing between page-based and pageless routes.
///
/// ## Route Types
///
/// YxNavigation needs to distinguish between two types of routes:
///
/// * **Page-based routes** - Created declaratively via [RouteDeclaration].
///   These are part of Navigator 2.0 architecture.
///
/// * **Pageless routes** - Created imperatively via
///   Navigator 1.0 API (e.g., `Navigator.push(MaterialPageRoute())`).
///
/// This extension provides utilities to:
/// - Check if a route is page-based or pageless via [isPageBased]
/// - Access the original Navigator 1.0 [Route] via [nativeRoute]
/// - Retrieve the [Page] wrapper created by compatibility layer via [pageFactory]
/// - Get the result [Completer] for pop operations via [resultCompleter]
///
/// ## Usage
///
/// These utilities are primarily used internally by
/// [NavigatorCompatibilityOverrides] to manage lifecycle and state
/// synchronization of pageless routes.
///
/// Example of checking route type:
///
/// ```dart
/// final node = RouteNode.fromRoute(route: MyRoutes.home);
///
/// if (node.isPageBased) {
///   print('Declarative route from RouteDeclaration');
/// } else {
///   final originalRoute = node.nativeRoute;
///   print('Pageless route: ${originalRoute?.settings.name}');
/// }
/// ```
///
/// See also:
///
/// * [NavigatorCompatibilityOverrides], which uses these utilities
/// * [RouteNode], the state tree node this extension operates on
/// {@endtemplate}
extension RouteNodeCompatibilityExtension on RouteNode {
  /// Checks if this [RouteNode] represents a page-based (declarative) route.
  ///
  /// Returns `true` if the route was created via [RouteDeclaration],
  /// meaning it's part of the declarative navigation tree.
  ///
  /// Returns `false` if the route was created via Navigator 1.0 API
  /// (e.g., `Navigator.push()`, `showDialog()`), making it a pageless route.
  ///
  /// ## Implementation
  ///
  /// A route is considered pageless if it contains the special
  /// [NavigatorCompatibilityOverrides.routeExtraKey] in its [extra] map.
  /// This key is added by [NavigatorCompatibilityOverrides] when wrapping
  /// Navigator 1.0 routes.
  @internal
  bool get isPageBased =>
      !extra.containsKey(NavigatorCompatibilityOverrides.routeExtraKey);

  /// Gets the arguments passed to the original Navigator 1.0 route.
  ///
  /// Returns the [RouteSettings.arguments] from the original [Route],
  /// or `null` if this is a page-based route or no arguments were provided.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Navigator 1.0 code:
  /// Navigator.push(MaterialPageRoute(
  ///   settings: RouteSettings(
  ///     name: 'details',
  ///     arguments: {'id': 123},
  ///   ),
  ///   builder: (context) => DetailsPage(),
  /// ));
  ///
  /// // Later, in compatibility layer:
  /// final args = node.nativeArguments as Map<String, dynamic>?;
  /// print(args?['id']); // 123
  /// ```
  @internal
  Object? get nativeArguments {
    if (isPageBased) {
      return null;
    }

    if (extra
        case {
          NavigatorCompatibilityOverrides.argumentsExtraKey: final Object?
              arguments
        }) {
      return arguments;
    }

    return null;
  }

  /// Gets the name (route ID) from the original Navigator 1.0 route.
  ///
  /// Returns the [RouteSettings.name] or a generated ID if none was provided.
  ///
  /// Throws [Exception] if this is a pageless route but no name is available,
  /// which should never happen as [NavigatorCompatibilityOverrides] always
  /// generates an ID.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Navigator 1.0 code:
  /// Navigator.push(MaterialPageRoute(
  ///   settings: RouteSettings(name: 'profile'),
  ///   builder: (context) => ProfilePage(),
  /// ));
  ///
  /// // Later:
  /// print(node.nativeName); // 'profile'
  /// ```
  @internal
  String get nativeName {
    if (isPageBased) {
      return route.id;
    }

    if (extra
        case {
          NavigatorCompatibilityOverrides.routeIdExtraKey: final String name
        }) {
      return name;
    }

    throw Exception('There is no provided name for RouteNode!');
  }

  /// Gets the original Navigator 1.0 [Route] object.
  ///
  /// Returns the [Route] that was passed to `Navigator.push()` or similar
  /// Navigator 1.0 API, or `null` if this is a page-based route.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final route = node.nativeRoute;
  /// if (route is MaterialPageRoute) {
  ///   print('Material route with animation');
  /// }
  /// ```
  @internal
  Route<Object?>? get nativeRoute {
    if (isPageBased) {
      return null;
    }

    if (extra
        case {
          NavigatorCompatibilityOverrides.routeExtraKey: final Route route
        }) {
      return route;
    }

    return null;
  }

  /// Gets the [Page] object created by compatibility layer for this route.
  ///
  /// When Navigator 1.0 routes are integrated into YxNavigation, they are
  /// wrapped in [Page] objects to make them compatible with Navigator 2.0
  /// architecture. This getter returns that [Page] wrapper.
  ///
  /// Returns `null` if this is a page-based route, as page-based routes
  /// create their own [Page] objects via [RouteDeclaration].
  @internal
  Page<Object?>? get pageFactory {
    if (isPageBased) {
      return null;
    }

    if (extra
        case {
          NavigatorCompatibilityOverrides.pageFactoryExtraKey:
              final Page<dynamic> page
        }) {
      return page;
    }

    return null;
  }

  /// Gets the [Completer] used to return results from this route.
  ///
  /// When a route is pushed via Navigator 1.0 API, it returns a [Future]
  /// that completes when the route is popped:
  ///
  /// ```dart
  /// final result = await Navigator.push(...);
  /// ```
  ///
  /// This completer is used to fulfill that future. When the route is
  /// popped, [NavigatorCompatibilityOverrides] completes this completer
  /// with the pop result.
  ///
  /// Returns `null` for page-based routes.
  @internal
  Completer<Object?>? get resultCompleter {
    if (isPageBased) {
      return null;
    }

    final completer = extra[NavigatorCompatibilityOverrides.completerExtraKey];
    if (completer != null && completer is Completer<Object?>) {
      return completer;
    }

    return null;
  }
}
