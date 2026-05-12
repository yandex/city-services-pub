import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../base/back_button_handler.dart';
import '../base/route_node_builder.dart';
import '../config/navigation_config_provider.dart';
import '../config/navigation_defaults.dart';
import '../extensions/build_context_extension.dart';
import '../router/yx_navigation.dart';
import 'yx_navigator.dart';

/// Signature for wrapping a nested navigator with additional widgets.
///
/// Passed to components such as `NavigatorOutlet` and [YxRouterDelegate]
/// to inject layout, theming, or dependency scopes around the nested
/// [Navigator].
typedef NavigatorBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

/// {@template navigator_outlet}
/// NavigatorOutlet widget.
/// {@endtemplate}
class NavigatorOutlet extends StatefulWidget {
  /// Current route node state
  final RouteNode routeNode;

  /// The key to use for this navigator.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The delegate that decides how the route transition animation should
  /// look like.
  final TransitionDelegate<Object?>? transitionDelegate;

  /// The list of observers for this navigator.
  final List<NavigatorObserver> observers;

  /// The restoration scope id to use for this navigator.
  final String? restorationScopeId;

  /// {@macro back_button_handler}
  ///
  /// By default, [DefaultBackButtonHandler] is used.
  final BackButtonHandler? backButtonHandler;

  /// {@macro state_manager}
  final RouteNodeStateManager? stateManager;

  /// {@macro navigation_controller}
  final NavigationController? navigationController;

  /// {@macro route_node_builder}
  final RouteNodeBuilder? routeNodeBuilder;

  /// The wrapper over the navigator.
  final NavigatorBuilder builder;

  /// Default builder for the navigator.
  static Widget _builder(BuildContext context, Widget navigator) => navigator;

  /// Creates an [NavigatorOutlet] widget.
  ///
  /// {@macro navigator_outlet}
  const NavigatorOutlet({
    required this.routeNode,
    this.navigationController,
    this.navigatorKey,
    this.transitionDelegate,
    this.observers = const <NavigatorObserver>[],
    this.restorationScopeId,
    this.backButtonHandler,
    this.routeNodeBuilder,
    this.builder = _builder,
    super.key,
  }) : stateManager = null;

  /// Creates an [NavigatorOutlet] widget for RouterDelegate.
  ///
  /// {@macro navigator_outlet}
  @internal
  const NavigatorOutlet.delegate({
    required this.routeNode,
    required this.stateManager,
    required this.routeNodeBuilder,
    required this.navigatorKey,
    this.transitionDelegate,
    this.observers = const <NavigatorObserver>[],
    this.restorationScopeId,
    this.backButtonHandler,
    this.builder = _builder,
    super.key,
  }) : navigationController = stateManager;

  @override
  State<NavigatorOutlet> createState() => _NavigatorOutletState();
}

class _NavigatorOutletState extends State<NavigatorOutlet> {
  /// Navigator key
  late final GlobalKey<NavigatorState> _navigatorKey;

  /// {@macro state_manager}
  late final RouteNodeStateManager _stateManager;

  /// {@macro route_node_builder}
  late final RouteNodeBuilder _routeNodeBuilder;

  /// {@macro route_node_resolver}
  late RouteNodeResolver _routeNodeResolver;

  /// {@macro navigation_controller}
  NavigationController? _nodeNavigationController;

  Completer<void>? _popCompleter;

  NavigationController get _resolvedNavigationController {
    final controller = widget.navigationController ?? _nodeNavigationController;
    if (controller == null) {
      throw StateError('Navigation controller should not be null');
    }
    return controller;
  }

  /// {@macro back_button_handler}
  late BackButtonHandler _backButtonHandler;

  List<RoutePageEntry> _pageEntries = const [];

  @override
  void initState() {
    super.initState();
    _navigatorKey = widget.navigatorKey ?? GlobalKey<NavigatorState>();
    _stateManager = widget.stateManager ?? context.stateManager;
    _routeNodeBuilder = widget.routeNodeBuilder ?? context.routeNodeBuilder;
    _backButtonHandler =
        widget.backButtonHandler ?? const DefaultBackButtonHandler();
    _resolveNavigationController();
  }

  @override
  void didUpdateWidget(covariant NavigatorOutlet oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isRouteNodeEquals = widget.routeNode.equalsBy(
      oldWidget.routeNode,
      equality: const RouteNodeEquality.routeAndArguments(),
    );

    if (!isRouteNodeEquals) {
      _nodeNavigationController?.close();
      _resolveNavigationController();
    }

    if (oldWidget.backButtonHandler != widget.backButtonHandler) {
      _backButtonHandler =
          widget.backButtonHandler ?? const DefaultBackButtonHandler();
    }
  }

  @override
  Widget build(BuildContext context) => YxNavigation.provider(
        routeNode: widget.routeNode,
        stateManager: _stateManager,
        navigationController: _resolvedNavigationController,
        parentNavigationController:
            YxNavigation.navigationControllerOf(context) ?? _stateManager,
        routeNodeBuilder: _routeNodeBuilder,
        child: Builder(
          builder: (context) => widget.builder(
            context,
            Builder(
              builder: (context) {
                _pageEntries = _routeNodeBuilder
                    .buildPages(
                      context,
                      widget.routeNode.children,
                    )
                    .toList();

                final pages = _pageEntries
                    .map((entry) => entry.page)
                    .toList(growable: false);

                final Widget child;
                if (pages.isEmpty) {
                  child = _routeNodeBuilder.emptyWidgetBuilder(
                    context,
                    widget.routeNode,
                  );
                } else {
                  child = BackButtonListener(
                    onBackButtonPressed: () => _onBackButtonPressed(context),
                    child: YxNavigator(
                      key: _navigatorKey,
                      navigationController: _resolvedNavigationController,
                      popCompleterProvider: () => _popCompleter,
                      pages: pages,
                      onDidRemovePage: _onDidRemovePage,
                      restorationScopeId: widget.restorationScopeId,
                      observers: widget.observers,
                      transitionDelegate: widget.transitionDelegate ??
                          NavigationDefaults.resolveNavigationDefaults(
                            context,
                          ).transitionDelegate,
                      overrides: NavigationConfigProvider.navigatorOverridesOf(
                        context,
                      ),
                    ),
                  );
                }
                return child;
              },
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _nodeNavigationController?.close();
    super.dispose();
  }

  /// Creates a [NavigationController] instance for current route node
  /// if there is not explicit controller
  /// specified through [navigationController] property.
  void _resolveNavigationController() {
    if (widget.navigationController != null) {
      return;
    }

    _routeNodeResolver = RouteNodeResolver.full(
      route: widget.routeNode.route,
      arguments: widget.routeNode.arguments,
    );
    _nodeNavigationController = NavigationController.node(
      stateManager: _stateManager,
      nodeResolver: _routeNodeResolver,
    );
  }

  void _onDidRemovePage(Page<Object?> page) {
    final pageEntryToRemove =
        _pageEntries.where((entry) => entry.page.key == page.key).firstOrNull;

    if (pageEntryToRemove == null) {
      return;
    }

    _pageEntries.remove(pageEntryToRemove);
    final node = pageEntryToRemove.routeNode;
    _resolvedNavigationController.mutate(
      (routeNode) {
        if (routeNode.children.length < 2) {
          return routeNode;
        }

        routeNode.removeWhere(
          (value) => value.equalsBy(
            node,
            equality: const RouteNodeEquality.routeAndArguments(),
          ),
        );
        return routeNode;
      },
    );
  }

  Future<bool> _onBackButtonPressed(BuildContext context) {
    if (!mounted) {
      return SynchronousFuture<bool>(false);
    }

    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      return SynchronousFuture<bool>(false);
    }

    return _backButtonHandler.call(context, widget.routeNode, navigator);
  }
}
