import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../yx_navigation_flutter_compatibility.dart';
import '../config/navigation_defaults.dart';
import 'navigator_overrides.dart';

typedef PopCompleterProvider = Completer<void>? Function();

/// {@template yx_navigator}
/// YxNavigator widget.
/// {@endtemplate}
@internal
@immutable
class YxNavigator extends Navigator {
  final NavigationController _navigationController;

  final NavigatorOverrides? _overrides;

  final PopCompleterProvider _popCompleterProvider;

  /// Creates an [YxNavigator] widget.
  ///
  /// {@macro yx_navigator}
  @internal
  const YxNavigator({
    required super.pages,
    required super.onDidRemovePage,
    required NavigationController navigationController,
    required PopCompleterProvider popCompleterProvider,
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
    }

    return super.push(route);
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
    }
    return super.pushAndRemoveUntil(newRoute, predicate);
  }

  @override
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> newRoute, {
    TO? result,
  }) {
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
