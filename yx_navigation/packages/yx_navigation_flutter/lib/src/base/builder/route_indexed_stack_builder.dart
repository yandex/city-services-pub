import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../page_factory/page_factory.dart';
import '../../widgets/route_node_indexed_stack.dart';
import 'route_builder.dart';

/// Signature for a function that builds the wrapper widget around the
/// `IndexedStack` produced by [RouteIndexedStackBuilder].
///
/// Receives the underlying [child] (the live `IndexedStack`) and an
/// [ActiveRouteController] for switching between tabs.
typedef RouteNodeIndexedBuilder = Widget Function(
  BuildContext context,
  RouteNode routeNode,
  Widget child,
  ActiveRouteController controller,
);

/// {@template route_indexed_stack_builder}
/// A [RouteBuilder] that renders the route's children inside an
/// `IndexedStack`.
///
/// Attached to a route declaration, it provides a tab-like UI where every
/// child retains its state while only the active one is visible.
/// {@endtemplate}
@immutable
class RouteIndexedStackBuilder<T> implements RouteBuilder<T> {
  /// Wrapper widget builder that decorates the `IndexedStack` (e.g. with a
  /// `BottomNavigationBar` or `TabBar`).
  final RouteNodeIndexedBuilder indexedBuilder;

  @override
  final PageFactory<T>? pageFactory;

  @override
  RouteNodeContentBuilder get builder => _builder;

  /// {@macro route_indexed_stack_builder}
  const RouteIndexedStackBuilder({
    required this.indexedBuilder,
    this.pageFactory,
  });

  Widget _builder(BuildContext context, RouteNode routeNode) =>
      RouteNodeIndexedStack(
        routeNode: routeNode,
        indexedStackBuilder: indexedBuilder,
      );
}
