import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../page_factory/page_factory.dart';
import '../../widgets/navigator_outlet.dart';
import '../back_button_handler.dart';
import 'route_builder.dart';

/// Signature for a function that wraps the nested [Navigator] mounted by a
/// [RouteOutletBuilder].
///
/// Use it to inject inherited widgets, scopes, or chrome around the
/// [outlet] without disturbing the route's nested navigation state.
typedef RouteNodeOutletBuilder = Widget Function(
  BuildContext context,
  RouteNode routeNode,
  Widget outlet,
);

/// {@template route_outlet_builder}
/// A [RouteBuilder] that mounts a nested [Navigator] for a route.
///
/// Attached to a route declaration, it hosts the route's children as a
/// stack managed by a dedicated navigator. Use [outletBuilder] to wrap
/// the nested navigator with additional chrome or dependency scopes.
/// {@endtemplate}
@immutable
class RouteOutletBuilder<T> implements RouteBuilder<T> {
  /// Optional key for the nested [Navigator].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Observers attached to the nested [Navigator].
  final Iterable<NavigatorObserver>? navigatorObservers;

  /// Delegate that decides how route transition animations look.
  final TransitionDelegate<Object?>? transitionDelegate;

  /// Restoration scope id for the nested [Navigator].
  final String? restorationScopeId;

  /// {@macro back_button_handler}
  final BackButtonHandler? backButtonHandler;

  /// Optional wrapper around the nested navigator. Receives the live
  /// [Widget] outlet and can decorate it with scopes or chrome.
  final RouteNodeOutletBuilder? outletBuilder;

  /// Navigation controller for the nested navigator. When `null`, a fresh
  /// [NavigationController] is created and provided to the subtree.
  final NavigationController? navigationController;

  @override
  final PageFactory<T>? pageFactory;

  @override
  RouteNodeContentBuilder get builder => _builder;

  /// {@macro route_outlet_builder}
  const RouteOutletBuilder({
    this.navigatorKey,
    this.navigatorObservers,
    this.transitionDelegate,
    this.restorationScopeId,
    this.backButtonHandler,
    this.outletBuilder,
    this.navigationController,
    this.pageFactory,
  });

  Widget _builder(BuildContext context, RouteNode routeNode) => NavigatorOutlet(
        routeNode: routeNode,
        navigatorKey: navigatorKey,
        observers: navigatorObservers?.toList() ?? const [],
        transitionDelegate: transitionDelegate,
        restorationScopeId: restorationScopeId,
        backButtonHandler: backButtonHandler,
        navigationController: navigationController,
        builder: (context, child) {
          final builder = outletBuilder;
          if (builder != null) {
            return builder(context, routeNode, child);
          }
          return child;
        },
      );
}
