import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../state/base/mutation.dart';
import 'equality/route_node_equality.dart';
import 'route.dart';
import 'route_node.dart';
import 'route_observer/route_node_diff_result.dart';

@internal
abstract class RouteNodeUtil {
  static Map<String, String> mutableArguments(
    Map<String, String> arguments,
  ) =>
      Map<String, String>.from(arguments);

  static Map<String, String> immutableArguments(
    Map<String, String> arguments,
  ) =>
      Map<String, String>.unmodifiable(arguments);

  static Map<String, Object?> mutableExtra(
    Map<String, Object?> extra,
  ) =>
      Map<String, Object?>.from(extra);

  static Map<String, Object?> immutableExtra(
    Map<String, Object?> extra,
  ) =>
      Map<String, Object?>.unmodifiable(extra);

  static MutableRouteNode mutableRouteNode(RouteNode routeNode) =>
      MutableRouteNode.fromRouteNode(routeNode);

  static ImmutableRouteNode immutableRouteNode(RouteNode routeNode) =>
      ImmutableRouteNode.fromRouteNode(routeNode);

  static List<MutableRouteNode> mutableRouteNodes(
    Iterable<RouteNode> routeNodes,
  ) =>
      routeNodes.map(mutableRouteNode).toList();

  static List<ImmutableRouteNode> immutableRouteNodes(
    Iterable<RouteNode> routeNodes,
  ) =>
      List<ImmutableRouteNode>.unmodifiable(routeNodes.map(immutableRouteNode));

  /// {@template route_node_util.traverse}
  /// Applies [action] to the given `routeNode` and to each of its `children`
  /// of type `N`.
  ///
  /// If [action] returns true, stops traversal.
  ///
  /// If [recursive] is true, also traverses descendants of each child.
  ///
  /// If [predicate] is null, then [action] is applied to all processed nodes.
  /// {@endtemplate}
  static void traverse<N extends RouteNode>(
    N routeNode,
    RouteNodeAction<N> action, {
    RouteNodePredicate<N>? predicate,
    bool recursive = true,
  }) {
    if (predicate == null || predicate(routeNode)) {
      if (action(routeNode)) {
        return;
      }
    }

    final children = Queue<N>.from(routeNode.children.whereType<N>());
    while (children.isNotEmpty) {
      final node = children.removeFirst();

      if (predicate == null || predicate(node)) {
        if (action(node)) {
          return;
        }
      }

      if (recursive) {
        children.addAll(node.children.cast<N>());
      }
    }
  }

  /// {@template route_node_util.traverse_children}
  /// Applies [action] to each direct child of the given `routeNode` of type `N`.
  ///
  /// If [action] returns true, stops traversal.
  ///
  /// If [recursive] is true, also traverses deeper descendants.
  ///
  /// If [predicate] is null, then [action] is applied to all processed nodes.
  /// {@endtemplate}
  static void traverseChildren<N extends RouteNode>(
    N routeNode,
    RouteNodeAction<N> action, {
    RouteNodePredicate<N>? predicate,
    bool recursive = true,
  }) {
    final children = Queue<N>.from(routeNode.children.whereType<N>());

    while (children.isNotEmpty) {
      final node = children.removeFirst();

      if (predicate == null || predicate(node)) {
        if (action(node)) {
          return;
        }
      }

      if (recursive) {
        children.addAll(node.children.cast<N>());
      }
    }
  }

  static N? find<N extends RouteNode>(
    N routeNode,
    RouteNodePredicate<N> predicate, {
    bool recursive = true,
  }) {
    N? result;

    traverse<N>(
      routeNode,
      (node) {
        result = node;
        return true;
      },
      predicate: (node) => predicate(node) && result == null,
      recursive: recursive,
    );

    return result;
  }

  static N? findByRoute<N extends RouteNode>(
    N routeNode,
    YxRoute route, {
    bool recursive = true,
  }) =>
      find<N>(
        routeNode,
        (node) => node.route == route,
        recursive: recursive,
      );

  /// {@template route_node_util.compare_nodes}
  /// Compares two route nodes and returns a diff result.
  /// {@endtemplate}
  static RouteNodeDiffResult compareNodes(
    RouteNode originalNode,
    RouteNode targetNode,
  ) {
    final originalFlattenNodes = _flattenRouteNodes(originalNode);
    final targetFlattenNodes = _flattenRouteNodes(targetNode);

    final originalFlattenNodeKeys = originalFlattenNodes.keys.toSet();
    final targetFlattenNodeKeys = targetFlattenNodes.keys.toSet();

    final addedKeys =
        _computeAdded(originalFlattenNodeKeys, targetFlattenNodeKeys);
    final removedKeys =
        _computeRemoved(originalFlattenNodeKeys, targetFlattenNodeKeys);

    final intersectionKeys =
        originalFlattenNodeKeys.intersection(targetFlattenNodeKeys);

    final changedKeys = _computeChanged(
      originalFlattenNodes,
      targetFlattenNodes,
      intersectionKeys,
    );

    return RouteNodeDiffResult(
      {
        for (final route in addedKeys) route: targetFlattenNodes[route]!,
      },
      {
        for (final route in removedKeys) route: originalFlattenNodes[route]!,
      },
      changedKeys,
    );
  }

  static Map<YxRoute, RouteNode> _flattenRouteNodes(RouteNode root) {
    final nodes = <YxRoute, RouteNode>{};
    final stack = [root];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (nodes.containsKey(node.route)) {
        continue;
      }
      nodes[node.route] = node;
      stack.addAll(node.children);
    }

    return nodes;
  }

  static Set<YxRoute> _computeAdded(
    Set<YxRoute> originalKeys,
    Set<YxRoute> targetKeys,
  ) =>
      targetKeys.difference(originalKeys);

  static Set<YxRoute> _computeRemoved(
    Set<YxRoute> originalKeys,
    Set<YxRoute> targetKeys,
  ) =>
      originalKeys.difference(targetKeys);

  static Map<YxRoute, Mutation> _computeChanged(
    Map<YxRoute, RouteNode> originalNodes,
    Map<YxRoute, RouteNode> targetNodes,
    Set<YxRoute> intersectionKeys,
  ) {
    final changed = <YxRoute, Mutation>{};
    for (final id in intersectionKeys) {
      final originalNode = originalNodes[id];
      final targetNode = targetNodes[id];

      if (originalNode == null || targetNode == null) {
        continue;
      }

      if (!const RouteNodeEquality.routeAndArgumentsAndExtra()
          .equals(originalNode, targetNode)) {
        changed[targetNode.route] = Mutation(
          originalState: originalNode,
          targetState: targetNode,
        );
        continue;
      }

      final originalChildrenRoutes =
          originalNode.children.map((c) => c.route).toList();
      final targetChildrenRoutes =
          targetNode.children.map((c) => c.route).toList();

      if (!const ListEquality<YxRoute>()
          .equals(originalChildrenRoutes, targetChildrenRoutes)) {
        changed[targetNode.route] = Mutation(
          originalState: originalNode,
          targetState: targetNode,
        );
      }
    }

    return changed;
  }
}
