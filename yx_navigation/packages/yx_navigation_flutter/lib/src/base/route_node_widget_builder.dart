import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../router/route_node_provider.dart';
import 'declaration/route_declaration.dart';

/// {@template route_node_widget_builder}
/// Builds the widget presented for a route node.
///
/// Wraps the widget produced by a [RouteDeclaration] in a
/// [RouteNodeProvider] so descendants can resolve the enclosing
/// [RouteNode]. Provides fallbacks for unknown and empty routes that can be
/// overridden by subclassing.
/// {@endtemplate}
@immutable
class RouteNodeWidgetBuilder {
  /// {@macro route_node_widget_builder}
  const RouteNodeWidgetBuilder();

  /// Builds the widget for [routeNode] using [declaration].
  Widget toWidget(
    BuildContext context,
    RouteNode routeNode,
    RouteDeclaration declaration,
  ) =>
      RouteNodeProvider(
        routeNode: routeNode,
        child: Builder(
          builder: (context) {
            final builder = declaration.routeBuilder;
            return builder.builder(context, routeNode);
          },
        ),
      );

  /// Builds a placeholder widget when no declaration matches [routeNode].
  Widget toNotFoundWidget(
    BuildContext context,
    RouteNode routeNode,
  ) =>
      RouteNodeProvider(
        routeNode: routeNode,
        child: Builder(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Not found page')),
          ),
        ),
      );

  /// Builds a placeholder widget shown when the route has no children.
  Widget toEmptyWidget(
    BuildContext context,
    RouteNode routeNode,
  ) =>
      RouteNodeProvider(
        routeNode: routeNode,
        child: Builder(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Empty page')),
          ),
        ),
      );
}
