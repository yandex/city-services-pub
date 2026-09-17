import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../yx_navigation_flutter_compatibility.dart';
import '../config/navigation_defaults.dart';
import 'navigator_overrides.dart';

typedef PopCompleterProvider = Completer<void>? Function();

/// Reports whether the pages handed to the [Navigator] still match the current
/// route tree.
///
/// Tree mutations are synchronous while `Navigator.pages` is rebuilt on the
/// next frame, so the two disagree for the rest of the current frame after any
/// mutation.
typedef PendingMutationProbe = bool Function();

/// {@template yx_navigator}
/// YxNavigator widget.
/// {@endtemplate}
@internal
@immutable
class YxNavigator extends Navigator {
  final NavigationController _navigationController;

  final NavigatorOverrides? _overrides;

  final PopCompleterProvider _popCompleterProvider;

  final PendingMutationProbe _hasPendingMutations;

  /// Creates an [YxNavigator] widget.
  ///
  /// {@macro yx_navigator}
  @internal
  const YxNavigator({
    required super.pages,
    required super.onDidRemovePage,
    required NavigationController navigationController,
    required PopCompleterProvider popCompleterProvider,
    required PendingMutationProbe hasPendingMutations,
    NavigatorOverrides? overrides,
    super.reportsRouteUpdateToEngine = false,
    super.clipBehavior = Clip.hardEdge,
    super.observers = const <NavigatorObserver>[],
    super.requestFocus = true,
    super.restorationScopeId,
    super.routeTraversalEdgeBehavior = kDefaultRouteTraversalEdgeBehavior,
    TransitionDelegate<Object?>? transitionDelegate,
    super.key,
  })  : _overrides = overrides,
        _navigationController = navigationController,
        _popCompleterProvider = popCompleterProvider,
        _hasPendingMutations = hasPendingMutations,
        super(
          transitionDelegate: transitionDelegate ??
              NavigationDefaults.defaultsTransitionDelegate,
        );

  @override
  NavigatorState createState() => _YxNavigatorNavigatorState();
}

class _YxNavigatorNavigatorState extends NavigatorState {
  @override
  Future<void> pop<T extends Object?>([T? result]) async {
    final widget = this.widget;
    if (widget is YxNavigator) {
      final routeNode = widget._navigationController.state;
      assert(
        routeNode != null && routeNode.children.length > 1,
        'RouteNode cannot be popped',
      );
      if (routeNode == null || routeNode.children.length < 2) {
        return;
      }

      final popOperation = widget._overrides?.pop;
      popOperation?.call(
        context: context,
        navigator: this,
        navigationController: widget._navigationController,
        result: result,
      );
    }

    super.pop(result);
  }

  @override
  Future<T?> push<T extends Object?>(Route<T> route) async {
    final Widget widget = this.widget;

    if (widget is YxNavigator) {
      final pushOperation = widget._overrides?.push;
      if (pushOperation != null) {
        try {
          return await pushOperation(
            context: context,
            navigator: this,
            popCompleterProvider: widget._popCompleterProvider,
            navigationController: widget._navigationController,
            route: route,
          );
        } on UnsupportedRouteException catch (error) {
          // Route cannot be handled by compatibility layer
          // (e.g., PopupMenuRoute without specialized adapter, or observer blocked)
          // Notify observer about failure before falling back to native Navigator
          widget._overrides?.observer?.didFailPagelessRoute(
            routeNodeReadable: widget._navigationController,
            route: route,
            error: error,
            routeNode: null,
          );

          // Bypass overrides and use native Navigator.push
          return super.push(route);
        }
      }

      _assertNoPendingMutations(widget, 'push');
    }

    return super.push(route);
  }

  /// Rejects an imperative route added on top of pages that no longer match
  /// the tree.
  ///
  /// Without compatibility overrides the route stays pageless, and Flutter
  /// ties a pageless route to the page below it, removing them together. A
  /// route added while the tree has already dropped that page is therefore
  /// dropped with it, and nothing in the declarative state records that it
  /// ever existed.
  ///
  /// Crossing that boundary is what the compatibility layer is for - the same
  /// boundary Flutter itself guards for replace operations.
  void _assertNoPendingMutations(YxNavigator widget, String operation) {
    assert(
      !widget._hasPendingMutations(),
      'Navigator.$operation was called while a route tree mutation has not '
      'reached Navigator.pages yet (they are rebuilt on the next frame).\n'
      '\n'
      'Without NavigatorCompatibilityOverrides the route stays pageless, and '
      'Flutter removes pageless routes together with the page they are tied '
      'to - so this route will be dropped with the outgoing page.\n'
      '\n'
      'Either install NavigatorCompatibilityOverrides through '
      'NavigationConfigProvider, or issue the imperative call after the '
      'pending mutation has been applied.',
    );
  }

  @override
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> newRoute,
    RoutePredicate predicate,
  ) async {
    final widget = this.widget;

    if (widget is YxNavigator) {
      final pushAndRemoveUntilOperation = widget._overrides?.pushAndRemoveUntil;
      if (pushAndRemoveUntilOperation != null) {
        try {
          return pushAndRemoveUntilOperation(
            context: context,
            navigator: this,
            popCompleterProvider: widget._popCompleterProvider,
            navigationController: widget._navigationController,
            route: newRoute,
            predicate: predicate,
          );
        } on UnsupportedRouteException catch (error) {
          // Route cannot be handled by compatibility layer
          // CRITICAL: Cannot fallback to native Navigator for replace operations
          // because Flutter prohibits mixing page-based and pageless routes

          // Notify observer about failure
          widget._overrides?.observer?.didFailPagelessRoute(
            routeNodeReadable: widget._navigationController,
            route: newRoute,
            error: error,
            routeNode: null,
          );

          throw UnsupportedRouteException(
            newRoute,
            'Route type ${newRoute.runtimeType} is not supported by compatibility layer. '
            'Cannot use native Navigator for pushAndRemoveUntil as it would mix '
            'page-based and pageless routes (forbidden by Flutter).\n'
            'Original error: ${error.message}',
          );
        }
      }

      // Reachable when the route on top is itself pageless: Flutter only
      // asserts on replacing a *page-based* route, so the operation goes
      // through and hits the same race as push.
      _assertNoPendingMutations(widget, 'pushAndRemoveUntil');
    }
    return super.pushAndRemoveUntil(newRoute, predicate);
  }

  @override
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> newRoute, {
    TO? result,
  }) async {
    final widget = this.widget;

    if (widget is YxNavigator) {
      final pushReplacementOperation = widget._overrides?.pushReplacement;
      if (pushReplacementOperation != null) {
        try {
          return pushReplacementOperation(
            context: context,
            navigator: this,
            popCompleterProvider: widget._popCompleterProvider,
            navigationController: widget._navigationController,
            route: newRoute,
            result: result,
          );
        } on UnsupportedRouteException catch (error) {
          // Route cannot be handled by compatibility layer
          // CRITICAL: Cannot fallback to native Navigator for replace operations
          // because Flutter prohibits mixing page-based and pageless routes

          // Notify observer about failure
          widget._overrides?.observer?.didFailPagelessRoute(
            routeNodeReadable: widget._navigationController,
            route: newRoute,
            error: error,
            routeNode: null,
          );

          throw UnsupportedRouteException(
            newRoute,
            'Route type ${newRoute.runtimeType} is not supported by compatibility layer. '
            'Cannot use native Navigator for pushReplacement as it would mix '
            'page-based and pageless routes (forbidden by Flutter).\n'
            'Original error: ${error.message}',
          );
        }
      }

      // Reachable when the route on top is itself pageless - see the note in
      // pushAndRemoveUntil.
      _assertNoPendingMutations(widget, 'pushReplacement');
    }

    return super.pushReplacement(newRoute, result: result);
  }

  @override
  void removeRoute<T extends Object?>(Route<T> route, [T? result]) {
    final widget = this.widget;

    if (widget is YxNavigator) {
      final removeRoute = widget._overrides?.removeRoute;
      if (removeRoute != null) {
        return removeRoute(
          context: context,
          navigator: this,
          navigationController: widget._navigationController,
          route: route,
          result: result,
        );
      }
    }

    return super.removeRoute(route, result);
  }
}
