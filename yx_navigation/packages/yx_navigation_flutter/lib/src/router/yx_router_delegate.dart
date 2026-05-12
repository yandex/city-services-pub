import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../base/back_button_handler.dart';
import '../base/route_declaration_resolver.dart';
import '../base/route_node_builder.dart';
import '../config/navigation_config_provider.dart';
import '../config/navigation_defaults.dart';
import '../debug_tools/debug_panel_display_type.dart';
import '../debug_tools/domain/debug_observer_readable.dart';
import '../debug_tools/domain/debug_panel_mode_notifier.dart';
import '../debug_tools/debug_panel_page_wrapper.dart';
import '../widgets/navigator_outlet.dart';

/// {@template yx_router_delegate}
/// [RouterDelegate] that renders the navigation tree held by a
/// [RouteNodeStateManager].
///
/// Builds a root [Navigator] from the current [RouteNode] tree, observes
/// state changes, and integrates optional debug tooling. Created as part of
/// the pipeline produced by [RouterSchema.build].
/// {@endtemplate}
class YxRouterDelegate extends RouterDelegate<RouteNode>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  /// The key used for the root [Navigator].
  @override
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Delegate that controls route transition animations.
  final TransitionDelegate<Object?>? transitionDelegate;

  /// Observers attached to the root [Navigator].
  final List<NavigatorObserver> observers;

  /// Restoration scope id forwarded to the root [Navigator].
  final String? restorationScopeId;

  /// Root state manager for the navigation tree.
  final RouteNodeStateManager stateManager;

  /// Builder that turns [RouteNode]s into [Page]s.
  final RouteNodeBuilder routeNodeBuilder;

  /// {@macro back_button_handler}
  final BackButtonHandler? backButtonHandler;

  /// Optional observer that feeds logs into the debug panel.
  final DebugObserverReadable? observerReadable;

  /// Optional notifier that controls debug panel visibility.
  final DebugPanelModeNotifier? debugPanelModeNotifier;

  /// Optional initial display type for the debug panel.
  final DebugPanelDisplayType? defaultDisplayType;

  /// Optional resolver used by the debug panel.
  final RouteDeclarationResolver? routeDeclarationResolver;

  /// Optional wrapper inserted around the root [Navigator].
  final NavigatorBuilder? builder;

  /// Subscription to state manager updates.
  late final StreamSubscription<RouteNode> _subscription;

  @override
  RouteNode get currentConfiguration => stateManager.state;

  /// Creates a [YxRouterDelegate].
  ///
  /// {@macro yx_router_delegate}
  YxRouterDelegate({
    required this.stateManager,
    required this.routeNodeBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    this.transitionDelegate,
    this.observers = const [],
    this.restorationScopeId,
    this.backButtonHandler,
    this.debugPanelModeNotifier,
    this.defaultDisplayType,
    this.observerReadable,
    this.routeDeclarationResolver,
    this.builder,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    _subscription = stateManager.stream.listen(
      (_) => notifyListeners(),
    );
  }

  static Widget _builder(BuildContext context, Widget navigator) => navigator;

  @override
  Widget build(BuildContext context) {
    final existingProvider = NavigationConfigProvider.maybeOf(context);

    final navigatorWidget = NavigatorOutlet.delegate(
      routeNode: stateManager.state,
      stateManager: stateManager,
      routeNodeBuilder: routeNodeBuilder,
      observers: observers,
      navigatorKey: navigatorKey,
      restorationScopeId: restorationScopeId,
      transitionDelegate: NavigationDefaults.resolveNavigationDefaults(context)
          .transitionDelegate,
      backButtonHandler: backButtonHandler,
      builder: (context, navigator) {
        Widget wrapped;

        final debugPanelListenable = debugPanelModeNotifier;
        if (debugPanelListenable != null) {
          wrapped = ListenableBuilder(
            listenable: debugPanelListenable,
            builder: (context, child) => debugPanelListenable.enableDebugPanel
                ? DebugPanelPageWrapper(
                    stateManager: stateManager,
                    routeDeclarationResolver: routeDeclarationResolver,
                    observerReadable: observerReadable,
                    defaultDisplayType: defaultDisplayType,
                    isVisible: debugPanelListenable.isInitiallyVisible,
                    child: child ?? const SizedBox.shrink(),
                  )
                : (child ?? const SizedBox.shrink()),
            child: navigator,
          );
        } else {
          wrapped = navigator;
        }

        final builder = this.builder ?? _builder;
        return builder.call(context, wrapped);
      },
    );

    if (existingProvider != null) {
      return navigatorWidget;
    }

    return NavigationConfigProvider(
      child: navigatorWidget,
    );
  }

  @override
  Future<void> setNewRoutePath(covariant RouteNode configuration) {
    stateManager.mutate((routeNode) => configuration);
    return SynchronousFuture<void>(null);
  }

  @mustCallSuper
  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    super.dispose();
  }
}
