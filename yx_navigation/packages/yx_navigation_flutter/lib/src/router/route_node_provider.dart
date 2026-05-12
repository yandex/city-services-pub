import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// {@template route_node_provider}
/// Exposes the enclosing [RouteNode] to descendants through an
/// [InheritedWidget].
///
/// Descendants resolve the node via [RouteNodeProvider.routeNodeOf] or
/// [RouteNodeProvider.routeNodeMaybeOf].
/// {@endtemplate}
class RouteNodeProvider extends InheritedWidget {
  /// The [RouteNode] exposed to descendants.
  final RouteNode routeNode;

  /// Creates a [RouteNodeProvider].
  ///
  /// {@macro route_node_provider}
  const RouteNodeProvider({
    required this.routeNode,
    required super.child,
    super.key,
  });

  /// Returns the [RouteNode] associated with the current [BuildContext].
  static RouteNode routeNodeOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _of(context, listen: listen).routeNode;

  /// Returns the [RouteNode] associated with the current [BuildContext],
  /// or `null` if there is no [RouteNodeProvider] widget in the tree.
  static RouteNode? routeNodeMaybeOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _maybeOf(context, listen: listen)?.routeNode;

  /// Returns the [RouteNodeProvider] associated with the current [BuildContext].
  static RouteNodeProvider _of(
    BuildContext context, {
    bool listen = true,
  }) {
    final result = _maybeOf(context, listen: listen);
    return ArgumentError.checkNotNull(result, 'RouteNodeProvider');
  }

  /// Returns the [RouteNodeProvider] associated with the current [BuildContext],
  /// or `null` if there is no [RouteNodeProvider] widget in the tree.
  static RouteNodeProvider? _maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<RouteNodeProvider>();
    }

    return context.getInheritedWidgetOfExactType<RouteNodeProvider>();
  }

  @override
  bool updateShouldNotify(RouteNodeProvider oldWidget) =>
      routeNode != oldWidget.routeNode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<RouteNode>(
        'routeNode',
        routeNode,
        showName: false,
      ),
    );
  }
}
