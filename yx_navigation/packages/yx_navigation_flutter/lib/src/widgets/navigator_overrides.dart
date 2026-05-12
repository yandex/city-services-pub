import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../compatibility/compatibility_observer.dart';
import 'yx_navigator.dart';

/// Signature for overriding `Navigator.pushAndRemoveUntil`.
typedef PushAndRemoveUntilOperation = Future<T?> Function<T extends Object?>({
  required Route<T> route,
  required BuildContext context,
  required NavigatorState navigator,
  required RoutePredicate predicate,
  required PopCompleterProvider popCompleterProvider,
  required NavigationController navigationController,
});

/// Signature for overriding `Navigator.push`.
typedef PushOperation = Future<T?> Function<T extends Object?>({
  required Route<T> route,
  required BuildContext context,
  required NavigatorState navigator,
  required PopCompleterProvider popCompleterProvider,
  required NavigationController navigationController,
});

/// Signature for overriding `Navigator.pushReplacement`.
typedef PushReplacementOperation = Future<T?>
    Function<T extends Object?, TO extends Object?>({
  required Route<T> route,
  required BuildContext context,
  required NavigatorState navigator,
  required PopCompleterProvider popCompleterProvider,
  required NavigationController navigationController,
  required TO? result,
});

/// Signature for overriding `Navigator.removeRoute`.
typedef RemoveRouteOperation = void Function({
  required Route<Object?> route,
  required BuildContext context,
  required NavigatorState navigator,
  required NavigationController navigationController,
  required Object? result,
});

/// Signature for generating a stable identifier for a pageless [Route].
///
/// The identifier is typically used to correlate pageless routes with entries
/// inside the navigation tree.
typedef RouteIdGenerator = String Function<T extends Object?>({
  required Route<T> route,
  required BuildContext context,
  required NavigatorState navigator,
  required NavigationController navigationController,
});

/// Signature for overriding `Navigator.pop`.
typedef PopOperation = void Function<T extends Object?>({
  required BuildContext context,
  required NavigatorState navigator,
  required NavigationController navigationController,
  required T? result,
});

/// {@template navigator_overrides}
/// App-wide overrides for [Navigator] operations.
///
/// A concrete subclass may replace any of the push/pop/remove operations with
/// custom logic, for example to integrate pageless routes with the declarative
/// navigation tree. Unspecified operations fall back to the standard
/// [NavigatorState] behaviour.
/// {@endtemplate}
abstract base class NavigatorOverrides {
  /// Custom implementation of `Navigator.pushAndRemoveUntil`.
  final PushAndRemoveUntilOperation? pushAndRemoveUntil;

  /// Custom implementation of `Navigator.pushReplacement`.
  final PushReplacementOperation? pushReplacement;

  /// Custom implementation of `Navigator.removeRoute`.
  final RemoveRouteOperation? removeRoute;

  /// Custom implementation of `Navigator.push`.
  final PushOperation? push;

  /// Custom implementation of `Navigator.pop`.
  final PopOperation? pop;

  /// Generator for stable pageless route identifiers.
  final RouteIdGenerator routeIdGenerator;

  /// Observer for pageless route lifecycle events.
  ///
  /// Used to notify about route creation or failure when bridging imperative
  /// [Route]s into the declarative navigation tree.
  final CompatibilityObserver? observer;

  /// Creates a [NavigatorOverrides] with the given operation overrides.
  ///
  /// {@macro navigator_overrides}
  const NavigatorOverrides({
    this.push,
    this.removeRoute,
    this.pushReplacement,
    this.pushAndRemoveUntil,
    this.pop,
    this.routeIdGenerator = _generateRouteId,
    this.observer,
  });

  /// Default instance that applies no overrides.
  const factory NavigatorOverrides.defaults() = _DefaultNavigatorOverrides;

  static String _generateRouteId<T extends Object?>({
    required Route<T> route,
    required BuildContext context,
    required NavigatorState navigator,
    required NavigationController navigationController,
  }) {
    final routeName = route.settings.name;
    final routeArguments = route.settings.arguments?.toString() ?? '';
    final routeBasedId =
        routeName != null ? '$routeName($routeArguments)' : null;

    return routeBasedId ?? DateTime.now().microsecondsSinceEpoch.toString();
  }
}

/// Default [NavigatorOverrides] implementation that applies no overrides.
final class _DefaultNavigatorOverrides extends NavigatorOverrides {
  const _DefaultNavigatorOverrides();
}
