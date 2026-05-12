import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'yx_route_information_parser.dart';
import 'yx_route_information_provider.dart';
import 'yx_router_delegate.dart';

/// {@template yx_router_config}
/// Flutter [RouterConfig] built by a [RouterSchema].
///
/// Bundles the parser, provider, delegate, and back button dispatcher into
/// the single value expected by `MaterialApp.router` or
/// `WidgetsApp.router`. The owning [State] must call [dispose] when the
/// router is no longer needed.
/// {@endtemplate}
final class YxRouterConfig implements RouterConfig<RouteNode> {
  @override
  final BackButtonDispatcher backButtonDispatcher;

  @override
  final YxRouteInformationParser? routeInformationParser;

  @override
  final YxRouteInformationProvider? routeInformationProvider;

  @override
  final YxRouterDelegate routerDelegate;

  /// Creates a [YxRouterConfig].
  ///
  /// {@macro yx_router_config}
  ///
  /// [routeInformationParser] and [routeInformationProvider] must either both
  /// be provided or both be `null`.
  const YxRouterConfig({
    required this.backButtonDispatcher,
    required this.routerDelegate,
    this.routeInformationParser,
    this.routeInformationProvider,
  }) : assert(
          (routeInformationProvider == null) ==
              (routeInformationParser == null),
          'RouteInformationProvider and RouteInformationParser '
          'must not be null',
        );

  /// Releases resources held by the [routerDelegate].
  ///
  /// Must be called by the owning [State.dispose].
  @mustCallSuper
  Future<void> dispose() => routerDelegate.dispose();
}
