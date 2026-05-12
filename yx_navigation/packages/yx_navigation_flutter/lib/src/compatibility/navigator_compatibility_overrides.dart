import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../config/navigation_defaults.dart';
import '../page_factory/pages_factory.dart';
import '../widgets/yx_navigator.dart';
import '../widgets/navigator_overrides.dart';
import 'compatibility_observer.dart';
import 'custom_route_page_factory_resolver.dart';
import 'route_node_compatibility_extension.dart';
import 'source_route_completer.dart';

/// Exception thrown when a route cannot be handled by compatibility layer
/// and must be pushed using native Navigator.
///
/// This is used internally by [YxNavigator] to detect routes that should
/// bypass compatibility overrides (e.g., PopupMenuRoute).
class UnsupportedRouteException implements Exception {
  final Route<Object?> route;
  final String message;

  const UnsupportedRouteException(this.route, this.message);

  @override
  String toString() =>
      'UnsupportedRouteException: $message (route: ${route.runtimeType})';
}

/// {@template navigator_compatibility_overrides}
/// Central component of the compatibility layer that adapts Navigator 1.0
/// operations for use with YxNavigation's declarative architecture.
///
/// ## Purpose
///
/// Enables seamless integration of legacy Navigator 1.0 code (pageless routes)
/// with YxNavigation (page-based routes) by:
///
/// 1. Intercepting Navigator 1.0 operations (`push`, `pop`, `pushReplacement`, etc.)
/// 2. Wrapping pageless routes in [Page] objects
/// 3. Synchronizing route state with [RouteNode] tree
/// 4. Managing route result [Completer]s for proper async behavior
///
/// ## Supported Operations
///
/// * `push` - Creates new pageless route
/// * `pop` - Closes route and returns result
/// * `pushReplacement` - Replaces current route
/// * `pushAndRemoveUntil` - Clears stack with predicate
/// * `removeRoute` - Removes specific route from stack
///
/// ## Supported Route Types
///
/// Out of the box support:
/// * [MaterialPageRoute]
/// * [CupertinoPageRoute]
/// * [ModalBottomSheetRoute]
/// * Any [ModalRoute] (via `modalRouteProxy` fallback)
///
/// Custom routes via [CustomRoutePageFactoryResolver].
///
/// ## Features
///
/// ### Observer
///
/// Register a [CompatibilityObserver] to monitor pageless route
/// lifecycle events for analytics, debugging, or migration tracking.
///
/// ## Usage
///
/// Register with [NavigationConfigProvider]:
///
/// ```dart
/// NavigationConfigProvider(
///   navigatorOverrides: NavigatorCompatibilityOverrides(
///     // Optional: custom route resolver
///     customRoutePageFactoryResolver: MyCustomResolver(),
///
///     // Optional: observer for analytics/debugging
///     observer: MyCompatibilityObserver(),
///   ),
///   child: MaterialApp.router(routerConfig: config),
/// )
/// ```
///
/// See also:
///
/// * [CompatibilityObserver], for monitoring route lifecycle events
/// * [CustomRoutePageFactoryResolver], for handling custom route types
/// * [NavigatorOverrides], the base class
/// * [SourceRouteCompleter], for route completion management
/// {@endtemplate}
final class NavigatorCompatibilityOverrides extends NavigatorOverrides {
  /// Key for storing [Page] in [RouteNode.extra].
  static const String pageFactoryExtraKey = '@pageFactory';

  /// Key for storing original [Route] in [RouteNode.extra].
  static const String routeExtraKey = '@route';

  /// Key for storing route ID in [RouteNode.extra].
  static const String routeIdExtraKey = '@routeId';

  /// Key for storing route arguments in [RouteNode.extra].
  static const String argumentsExtraKey = '@arguments';

  /// Key for storing result [Completer] in [RouteNode.extra].
  static const String completerExtraKey = '@completer';

  /// Resolver for custom route types.
  final CustomRoutePageFactoryResolver? _customRoutePageFactoryResolver;

  /// {@macro navigator_compatibility_overrides}
  const NavigatorCompatibilityOverrides({
    super.pushReplacement,
    super.pushAndRemoveUntil,
    super.removeRoute,
    super.push,
    super.routeIdGenerator,
    CustomRoutePageFactoryResolver? customRoutePageFactoryResolver,
    super.observer,
  }) : _customRoutePageFactoryResolver = customRoutePageFactoryResolver;

  @override
  PopOperation? get pop => _pop;

  @override
  PushOperation? get push => _push;

  @override
  PushAndRemoveUntilOperation? get pushAndRemoveUntil => _pushAndRemoveUntil;

  @override
  PushReplacementOperation? get pushReplacement => _pushReplacement;

  @override
  RemoveRouteOperation? get removeRoute => _removeRoute;

  RouteNode _attachPageFactory<T>({
    required Route<T> route,
    required BuildContext context,
    required NavigatorState navigator,
    required Completer<T?> routeCompleter,
    required NavigationController navigationController,
  }) {
    final routeId = routeIdGenerator.call(
      route: route,
      context: context,
      navigator: navigator,
      navigationController: navigationController,
    );

    final shouldProcess = observer?.willPushPagelessRoute(
            routeNodeReadable: navigationController,
            route: route,
            routeId: routeId) ??
        true;
    if (!shouldProcess) {
      throw UnsupportedRouteException(
        route,
        'Observer prevented processing of route type ${route.runtimeType}.',
      );
    }

    final node = _createNode(
      routeId: routeId,
      route: route,
    ).toMutable();

    final key = NavigationDefaults.resolveNavigationDefaults(context)
        .localKeyFactory
        .createKey(node);
    final customRoutePageFactoryResolver = _customRoutePageFactoryResolver;

    final sourceRouteCompleter = SourceRouteCompleter<T>(route);
    routeCompleter.future.then(
      sourceRouteCompleter.complete,
      onError: (error, stackTrace) {
        assert(() {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'yx_navigation_flutter',
              context: ErrorDescription(
                'Error in route adapter completion. '
                'Source route ($route) will complete with null.',
              ),
            ),
          );
          return true;
        }(), '');
        sourceRouteCompleter.complete(null);
      },
    );

    final Page<dynamic>? page;
    if (customRoutePageFactoryResolver != null &&
        customRoutePageFactoryResolver.hasResolverFor(route)) {
      page = customRoutePageFactoryResolver.resolvePage(
        routeCompleter: routeCompleter,
        route: route,
        key: key,
      );
    } else {
      page = _buildPageFactory<T>(
        routeCompleter: routeCompleter,
        route: route,
        routeNode: node,
        context: context,
        key: key,
      );
    }

    // If page is null, this route cannot be handled by compatibility layer.
    // This happens for PopupRoute types without specialized adapters (e.g., PopupMenuRoute).
    // These routes cannot be wrapped in PageRouteBuilder as it breaks their overlay logic.
    // Throw exception so YxNavigator can delegate to native Navigator (pageless mode).
    if (page == null) {
      throw UnsupportedRouteException(
        route,
        'Route type ${route.runtimeType} cannot be handled by compatibility layer. '
        'It will be pushed using native Navigator (pageless mode).',
      );
    }

    node.extra[pageFactoryExtraKey] = page;
    node.extra[completerExtraKey] = routeCompleter;
    final immutableNode = node.toImmutable();
    observer?.didCreatePagelessRoute(
      routeNodeReadable: navigationController,
      route: route,
      routeId: routeId,
      routeType: route.runtimeType.toString(),
      routeNode: immutableNode,
    );

    return immutableNode;
  }

  Page<T>? _buildPageFactory<T>({
    required Completer<T?> routeCompleter,
    required BuildContext context,
    required Route<T> route,
    required RouteNode routeNode,
    required LocalKey key,
  }) {
    // Priority 1: CupertinoPageRoute - full parameter support
    if (route is CupertinoPageRoute<T>) {
      return PagesFactory<T>.cupertino(
        routeCompleter: routeCompleter,
        fullscreenDialog: route.fullscreenDialog,
        allowSnapshotting: route.allowSnapshotting,
        maintainState: route.maintainState,
        title: route.title,
      ).call(
        context,
        routeNode,
        key,
        route.buildPage(
          context,
          route.animation ?? kAlwaysDismissedAnimation,
          route.secondaryAnimation ?? kAlwaysDismissedAnimation,
        ),
      );
    }

    // Priority 2: MaterialPageRoute - full parameter support
    if (route is MaterialPageRoute<T>) {
      return PagesFactory<T>.material(
        routeCompleter: routeCompleter,
        fullscreenDialog: route.fullscreenDialog,
        allowSnapshotting: route.allowSnapshotting,
        maintainState: route.maintainState,
      ).call(
        context,
        routeNode,
        key,
        route.buildPage(
          context,
          route.animation ?? kAlwaysDismissedAnimation,
          route.secondaryAnimation ?? kAlwaysDismissedAnimation,
        ),
      );
    }

    // Priority 3: ModalBottomSheetRoute - full parameter support
    if (route is ModalBottomSheetRoute<T>) {
      return PagesFactory<T>.modalBottomSheet(
        routeCompleter: routeCompleter,
        isScrollControlled: route.isScrollControlled,
        capturedThemes: route.capturedThemes,
        barrierLabel: route.barrierLabel,
        barrierOnTapHint: route.barrierOnTapHint,
        backgroundColor: route.backgroundColor,
        elevation: route.elevation,
        shape: route.shape,
        clipBehavior: route.clipBehavior,
        constraints: route.constraints,
        modalBarrierColor: route.modalBarrierColor,
        isDismissible: route.isDismissible,
        enableDrag: route.enableDrag,
        showDragHandle: route.showDragHandle,
        scrollControlDisabledMaxHeightRatio:
            route.scrollControlDisabledMaxHeightRatio,
        transitionAnimationController: route.transitionAnimationController,
        anchorPoint: route.anchorPoint,
        useSafeArea: route.useSafeArea,
      ).call(
        context,
        routeNode,
        key,
        Builder(builder: route.builder),
      );
    }

    // Priority 4: DialogRoute - preserves dialog positioning and behavior
    if (route is DialogRoute<T>) {
      return PagesFactory<T>.dialog(
        route: route,
        routeCompleter: routeCompleter,
        barrierDismissible: route.barrierDismissible,
        useSafeArea: true, // DialogRoute always uses safe area by default
        barrierColor: route.barrierColor,
        barrierLabel: route.barrierLabel,
        anchorPoint: route.anchorPoint,
      ).call(
        context,
        routeNode,
        key,
        const SizedBox.shrink(),
      );
    }

    // Priority 5: CupertinoDialogRoute - preserves Cupertino dialog behavior
    if (route is CupertinoDialogRoute<T>) {
      return PagesFactory<T>.cupertinoDialog(
        route: route,
        routeCompleter: routeCompleter,
        barrierDismissible: route.barrierDismissible,
        barrierColor: route.barrierColor,
        barrierLabel: route.barrierLabel,
        anchorPoint: route.anchorPoint,
      ).call(
        context,
        routeNode,
        key,
        const SizedBox.shrink(),
      );
    }

    // Priority 6: CupertinoModalPopupRoute - preserves slide-up behavior
    if (route is CupertinoModalPopupRoute<T>) {
      return PagesFactory<T>.cupertinoModalPopup(
        route: route,
        routeCompleter: routeCompleter,
        barrierColor: route.barrierColor,
        barrierDismissible: route.barrierDismissible,
        barrierLabel: route.barrierLabel,
        semanticsDismissible: route.semanticsDismissible,
        anchorPoint: route.anchorPoint,
      ).call(
        context,
        routeNode,
        key,
        const SizedBox.shrink(),
      );
    }

    // Priority 7: RawDialogRoute - low-level dialog route with custom transitions
    // Note: Must be checked AFTER CupertinoDialogRoute, as CupertinoDialogRoute extends RawDialogRoute
    if (route is RawDialogRoute<T>) {
      return PagesFactory<T>.rawDialog(
        route: route,
        routeCompleter: routeCompleter,
        barrierDismissible: route.barrierDismissible,
        transitionDuration: route.transitionDuration,
        reverseTransitionDuration: route.reverseTransitionDuration,
        barrierColor: route.barrierColor,
        barrierLabel: route.barrierLabel,
        anchorPoint: route.anchorPoint,
      ).call(
        context,
        routeNode,
        key,
        const SizedBox.shrink(),
      );
    }

    // Fallback: Check if this is a PopupRoute without specialized adapter.
    // PopupMenuRoute (private class) and other custom PopupRoute types
    // cannot be wrapped in PageRouteBuilder - it breaks their overlay/animation logic.
    // Return null to let YxNavigator push them natively (pageless mode).
    if (route is PopupRoute<T>) {
      return null;
    }

    // Fallback: Any other ModalRoute via proxy
    return PagesFactory.modalRouteProxy(
      route: route,
      arguments: routeNode.nativeArguments,
      name: routeNode.nativeName,
      routeCompleter: routeCompleter,
    ).call(
      context,
      routeNode,
      key,
      const SizedBox.shrink(),
    );
  }

  RouteNode _createNode<T>({
    required String routeId,
    required Route<T> route,
  }) =>
      RouteNode.fromRoute(
        route: YxRoute(id: routeId),
        extra: _wrapExtra(
          routeId: routeId,
          route: route,
        ),
      );

  void _pop<T extends Object?>({
    required BuildContext context,
    required NavigatorState navigator,
    required NavigationController navigationController,
    required T? result,
  }) {
    final poppedNode = navigationController.state?.children.last;
    final completer = poppedNode?.resultCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  Future<T?> _push<T extends Object?>({
    required Route<T> route,
    required BuildContext context,
    required NavigatorState navigator,
    required PopCompleterProvider popCompleterProvider,
    required NavigationController navigationController,
  }) async {
    final popCompleter = popCompleterProvider();
    if (popCompleter != null && !popCompleter.isCompleted) {
      await popCompleter.future;
    }

    final routeCompleter = Completer<T?>();
    final node = _attachPageFactory<T>(
      route: route,
      context: context,
      navigator: navigator,
      routeCompleter: routeCompleter,
      navigationController: navigationController,
    );

    navigationController.pushNode(node);
    return routeCompleter.future;
  }

  Future<T?> _pushAndRemoveUntil<T extends Object?>({
    required Route<T> route,
    required BuildContext context,
    required NavigatorState navigator,
    required PopCompleterProvider popCompleterProvider,
    required NavigationController navigationController,
    required RoutePredicate predicate,
  }) async {
    final popCompleter = popCompleterProvider();
    if (popCompleter != null && !popCompleter.isCompleted) {
      await popCompleter.future;
    }

    final routeCompleter = Completer<T?>();
    final node = _attachPageFactory<T>(
      route: route,
      context: context,
      navigator: navigator,
      routeCompleter: routeCompleter,
      navigationController: navigationController,
    );

    navigationController.mutate(
      (routeNode) {
        routeNode
          ..removeUntil(_wrapRoutePredicate(predicate), recursive: false)
          ..add(node);

        return routeNode;
      },
    );

    return routeCompleter.future;
  }

  Future<T?> _pushReplacement<T extends Object?, TO extends Object?>({
    required Route<T> route,
    required BuildContext context,
    required NavigatorState navigator,
    required PopCompleterProvider popCompleterProvider,
    required NavigationController navigationController,
    TO? result,
  }) async {
    final popCompleter = popCompleterProvider();
    if (popCompleter != null && !popCompleter.isCompleted) {
      await popCompleter.future;
    }

    final routeCompleter = Completer<T?>();
    final node = _attachPageFactory<T>(
      route: route,
      context: context,
      navigator: navigator,
      routeCompleter: routeCompleter,
      navigationController: navigationController,
    );

    navigationController.mutate(
      (routeNode) {
        routeNode.upsertLast(node);
        return routeNode;
      },
    );
    return routeCompleter.future;
  }

  void _removeRoute({
    required Route<Object?> route,
    required BuildContext context,
    required NavigatorState navigator,
    required NavigationController navigationController,
    required Object? result,
  }) =>
      navigationController.mutate(
        (routeNode) {
          routeNode.removeWhere(
            (value) =>
                !value.isPageBased &&
                value.nativeRoute == route &&
                routeNode.children.length > 1,
            recursive: false,
          );
          return routeNode;
        },
      );

  Map<String, Object?> _wrapExtra<T>({
    required String routeId,
    required Route<T> route,
  }) =>
      {
        routeExtraKey: route,
        routeIdExtraKey: routeId,
        argumentsExtraKey: route.settings.arguments,
      };

  RouteNodePredicate<RouteNode> _wrapRoutePredicate(
    RoutePredicate predicate,
  ) =>
      (node) {
        if (node.isPageBased) {
          return false;
        }
        final route = node.nativeRoute;
        if (route == null) {
          return false;
        }

        return predicate(route);
      };
}
