import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'equality/route_node_equality.dart';
import 'route.dart';
import 'route_node_util.dart';

/// Signature used to filter [RouteNode] instances during traversal
/// and lookup operations.
typedef RouteNodePredicate<N extends RouteNode> = bool Function(
  N routeNode,
);

/// Signature for callbacks invoked during [RouteNode] traversal.
///
/// Returning `true` stops further traversal.
typedef RouteNodeAction<N extends RouteNode> = bool Function(
  N routeNode,
);

/// Base class for all route node flavours.
@internal
abstract base class BaseRouteNode {
  const BaseRouteNode();

  /// Whether this node has any children.
  @nonVirtual
  bool get hasChildren => children.isNotEmpty;

  /// Whether this node carries any arguments.
  @nonVirtual
  bool get hasArguments => arguments.isNotEmpty;

  /// Whether this node carries any extra data.
  @nonVirtual
  bool get hasExtra => extra.isNotEmpty;

  /// The route that identifies this node in the navigation tree.
  abstract final YxRoute route;

  /// Serializable arguments associated with this node.
  ///
  /// These are shaped like URI query parameters and are included when a
  /// [RouteNode] is serialized to or from a [Uri].
  abstract final Map<String, String> arguments;

  /// Runtime-only payload attached to this node.
  ///
  /// Unlike [arguments], [extra] may contain arbitrary objects and complex
  /// structures that cannot be reconstructed from simple types. It is
  /// deliberately excluded from URI based serialization.
  abstract final Map<String, Object?> extra;

  /// Descendants or siblings of this node.
  ///
  /// The list can be interpreted differently at runtime. It may be a set of
  /// sibling branches, each with its own isolated navigator, or a navigation
  /// stack whose children are rendered one after another. The exact meaning
  /// is determined by the containing builder.
  abstract final Iterable<RouteNode> children;

  /// Returns a copy of this node with the given fields replaced.
  RouteNode copyWith({
    YxRoute? route,
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
    List<RouteNode>? children,
  });

  /// {@macro route_node_util.traverse}
  void traverse(
    RouteNodeAction<RouteNode> action, {
    RouteNodePredicate<RouteNode>? predicate,
    bool recursive = true,
  });

  /// {@macro route_node_util.traverse_children}
  void traverseChildren(
    RouteNodeAction<RouteNode> action, {
    RouteNodePredicate<RouteNode>? predicate,
    bool recursive = true,
  });

  /// Returns the first descendant (including `this`) that satisfies
  /// [predicate], or `null` when nothing matches.
  RouteNode? find(
    RouteNodePredicate predicate, {
    bool recursive = true,
  });

  /// Returns the first descendant (including `this`) whose route equals
  /// [route], or `null` when nothing matches.
  RouteNode? findByRoute(
    YxRoute route, {
    bool recursive = true,
  });
}

/// {@template route_node}
/// A node in the navigation tree.
///
/// A [RouteNode] pairs a [YxRoute] with serializable `arguments`, runtime-only
/// `extra` data, and a list of `children` that represent nested stacks or
/// sibling branches.
///
/// Two flavours exist:
/// - [MutableRouteNode], used when guards and mutations modify the tree.
/// - Immutable instances from [RouteNode.immutable] or [RouteNode.fromRoute]
///   for sealed snapshots of the current state.
///
/// Convert between them with [RouteNode.toMutable] and [RouteNode.toImmutable].
/// {@endtemplate}
@immutable
sealed class RouteNode extends BaseRouteNode {
  const RouteNode._();

  /// Creates a mutable node.
  factory RouteNode.mutable({
    required YxRoute route,
    required Map<String, String> arguments,
    required Map<String, Object?> extra,
    required List<RouteNode> children,
  }) = MutableRouteNode;

  /// Creates an immutable node.
  factory RouteNode.immutable({
    required YxRoute route,
    required Map<String, String> arguments,
    required Map<String, Object?> extra,
    required List<RouteNode> children,
  }) = ImmutableRouteNode;

  /// Creates an immutable node for [route] with optional arguments, extra
  /// data and children.
  factory RouteNode.fromRoute({
    required YxRoute route,
    Map<String, String> arguments = const {},
    Map<String, Object?> extra = const {},
    List<RouteNode> children = const [],
  }) =>
      ImmutableRouteNode(
        route: route,
        arguments: arguments,
        extra: extra,
        children: children,
      );

  /// Returns a mutable copy of this node.
  MutableRouteNode toMutable();

  /// Returns an immutable copy of this node.
  ImmutableRouteNode toImmutable();

  /// Returns `true` when [other] is considered equal to this node under
  /// the supplied [equality] strategy.
  ///
  /// Defaults to [RouteNodeEquality.deep], which recursively compares
  /// all fields including [children].
  bool equalsBy(
    RouteNode other, {
    Equality<RouteNode> equality = const RouteNodeEquality.deep(),
  }) =>
      equality.equals(this, other);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        route,
        const MapEquality().hash(arguments),
        const DeepCollectionEquality().hash(extra),
        const DeepCollectionEquality().hash(children),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteNode &&
          runtimeType == other.runtimeType &&
          route == other.route &&
          const MapEquality().equals(arguments, other.arguments) &&
          const DeepCollectionEquality().equals(extra, other.extra) &&
          const DeepCollectionEquality().equals(children, other.children));

  @override
  String toString() {
    final name = switch (this) {
      MutableRouteNode() => 'MutableRouteNode',
      ImmutableRouteNode() => 'ImmutableRouteNode',
    };
    return '$name(route: $route, arguments: $arguments, extra: $extra, children: $children)';
  }
}

/// Mutable flavour of [RouteNode].
///
/// This is the representation passed to guards and mutation callbacks so
/// that they can rearrange the tree in place. Call [toImmutable] to seal
/// the result once the mutation is complete.
final class MutableRouteNode extends RouteNode {
  @override
  final YxRoute route;

  @override
  final Map<String, String> arguments;

  @override
  final Map<String, Object?> extra;

  @override
  final List<MutableRouteNode> children;

  /// Creates a [MutableRouteNode] from individual fields.
  factory MutableRouteNode({
    required YxRoute route,
    required Map<String, String> arguments,
    required Map<String, Object?> extra,
    required Iterable<RouteNode> children,
  }) =>
      MutableRouteNode._(
        route: route,
        arguments: RouteNodeUtil.mutableArguments(arguments),
        extra: RouteNodeUtil.mutableExtra(extra),
        children: RouteNodeUtil.mutableRouteNodes(children),
      );

  /// Creates a [MutableRouteNode] for [route] with optional arguments,
  /// extra data and children.
  factory MutableRouteNode.fromRoute(
    YxRoute route, {
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
    List<RouteNode>? children,
  }) =>
      MutableRouteNode(
        route: route,
        arguments: arguments ?? const <String, String>{},
        extra: extra ?? const <String, Object?>{},
        children: children ?? const <RouteNode>[],
      );

  /// Creates a [MutableRouteNode] that mirrors the contents of
  /// [routeNode].
  factory MutableRouteNode.fromRouteNode(
    RouteNode routeNode,
  ) =>
      MutableRouteNode(
        route: routeNode.route,
        arguments: routeNode.arguments,
        extra: routeNode.extra,
        children: routeNode.children,
      );

  const MutableRouteNode._({
    required this.route,
    required this.arguments,
    required this.extra,
    required this.children,
  }) : super._();

  @override
  MutableRouteNode copyWith({
    YxRoute? route,
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
    List<RouteNode>? children,
  }) =>
      MutableRouteNode(
        route: route ?? this.route,
        arguments: arguments ?? this.arguments,
        extra: extra ?? this.extra,
        children: children ?? this.children,
      );

  @override
  ImmutableRouteNode toImmutable() => ImmutableRouteNode(
        route: route,
        arguments: arguments,
        extra: extra,
        children: children,
      );

  @override
  MutableRouteNode toMutable() => this;

  @override
  void traverse(
    RouteNodeAction<MutableRouteNode> action, {
    RouteNodePredicate<MutableRouteNode>? predicate,
    bool recursive = true,
  }) =>
      RouteNodeUtil.traverse<MutableRouteNode>(
        this,
        action,
        predicate: predicate,
        recursive: recursive,
      );

  @override
  void traverseChildren(
    RouteNodeAction<MutableRouteNode> action, {
    RouteNodePredicate<MutableRouteNode>? predicate,
    bool recursive = true,
  }) =>
      RouteNodeUtil.traverseChildren<MutableRouteNode>(
        this,
        action,
        predicate: predicate,
        recursive: recursive,
      );

  @override
  MutableRouteNode? find(
    RouteNodePredicate<MutableRouteNode> predicate, {
    bool recursive = true,
  }) =>
      RouteNodeUtil.find<MutableRouteNode>(
        this,
        predicate,
        recursive: recursive,
      );

  @override
  MutableRouteNode? findByRoute(
    YxRoute route, {
    bool recursive = true,
  }) =>
      RouteNodeUtil.findByRoute<MutableRouteNode>(
        this,
        route,
        recursive: recursive,
      );

  /// Adds [routeNode] to the end of the top level children.
  void add(RouteNode routeNode) {
    final value = RouteNodeUtil.mutableRouteNode(routeNode);
    return children.add(value);
  }

  /// Appends all of [routeNodes] to the end of the top level children.
  void addAll(Iterable<RouteNode> routeNodes) {
    if (routeNodes.isEmpty) {
      return;
    }

    final value = RouteNodeUtil.mutableRouteNodes(routeNodes);
    return children.addAll(value);
  }

  /// Adds [routeNode] to the end of the children list, or moves the
  /// existing entry to the end if a node with the same route is already
  /// present.
  ///
  /// When an existing entry is moved, its [arguments], [extra] and
  /// [children] are preserved. Only the position changes.
  void addOrMoveToEnd(RouteNode routeNode) {
    final activeRouteNode = children.firstWhereOrNull(
      (element) => element.route == routeNode.route,
    );

    if (activeRouteNode == null) {
      children.add(RouteNodeUtil.mutableRouteNode(routeNode));
      return;
    }

    final value = RouteNodeUtil.mutableRouteNode(activeRouteNode);
    children
      ..remove(activeRouteNode)
      ..add(value);
  }

  /// Inserts [routeNode] at [index] in the top level children.
  void insert(int index, RouteNode routeNode) {
    final value = RouteNodeUtil.mutableRouteNode(routeNode);
    return children.insert(index, value);
  }

  /// Inserts all of [routeNodes] starting at [index] in the top level
  /// children.
  void insertAll(int index, Iterable<RouteNode> routeNodes) {
    final value = RouteNodeUtil.mutableRouteNodes(routeNodes);
    return children.insertAll(index, value);
  }

  /// Replaces the first child with [routeNode], or adds it if [children]
  /// is empty.
  MutableRouteNode upsertFirst(RouteNode routeNode) {
    final value = RouteNodeUtil.mutableRouteNode(routeNode);
    if (children.isEmpty) {
      children.add(value);
    } else {
      children.first = value;
    }
    return value;
  }

  /// Replaces the last child with [routeNode], or adds it if [children]
  /// is empty.
  MutableRouteNode upsertLast(RouteNode routeNode) {
    final value = RouteNodeUtil.mutableRouteNode(routeNode);
    if (children.isEmpty) {
      children.add(value);
    } else {
      children.last = value;
    }
    return value;
  }

  /// Removes every node that satisfies [predicate].
  ///
  /// When [recursive] is `true`, the predicate is applied to the entire
  /// subtree. Returns the removed nodes.
  List<MutableRouteNode> removeWhere(
    RouteNodePredicate<MutableRouteNode> predicate, {
    bool recursive = true,
  }) {
    final result = <MutableRouteNode>[];

    void processChildren(List<MutableRouteNode> children) {
      for (var i = children.length - 1; i >= 0; i--) {
        final node = children[i];

        if (predicate(node)) {
          children.removeAt(i);
          result.add(node);
        } else if (recursive && node.children.isNotEmpty) {
          processChildren(node.children);
        }
      }
    }

    processChildren(children);
    return result;
  }

  /// Removes nodes from the end until [predicate] returns `true`.
  ///
  /// When [recursive] is `true`, the traversal descends into children.
  /// Returns the removed nodes.
  List<MutableRouteNode> removeUntil(
    RouteNodePredicate<MutableRouteNode> predicate, {
    bool recursive = true,
  }) {
    final removedNodes = <MutableRouteNode>[];

    bool processChildren(List<MutableRouteNode> children) {
      for (var i = children.length - 1; i >= 0; i--) {
        final node = children[i];

        if (predicate(node)) {
          return true;
        }

        children.removeAt(i);
        removedNodes.add(node);

        if (recursive && node.children.isNotEmpty) {
          final shouldStop = processChildren(node.children);
          if (shouldStop) {
            return true;
          }
        }
      }

      return false;
    }

    processChildren(children);
    return removedNodes;
  }

  /// Removes and returns the first child, or `null` if there are no
  /// children.
  MutableRouteNode? removeFirst() {
    if (children.isEmpty) {
      return null;
    }

    return children.removeAt(0);
  }

  /// Removes and returns the last child, or `null` if there are no
  /// children.
  MutableRouteNode? removeLast() {
    if (children.isEmpty) {
      return null;
    }

    return children.removeLast();
  }

  /// Replaces the current [arguments] with [arguments].
  void setArguments(Map<String, String> arguments) {
    final value = RouteNodeUtil.mutableArguments(arguments);

    this.arguments
      ..clear()
      ..addAll(value);
  }

  /// Removes every entry from [arguments].
  void clearArguments() => arguments.clear();

  /// Replaces the current [extra] with [extra].
  void setExtra(Map<String, Object?> extra) {
    final value = RouteNodeUtil.mutableExtra(extra);

    this.extra
      ..clear()
      ..addAll(value);
  }

  /// Removes every entry from [extra].
  void clearExtra() => extra.clear();

  /// Replaces the current [children] with [children].
  void setChildren(Iterable<RouteNode> children) {
    final value = RouteNodeUtil.mutableRouteNodes(children);

    this.children
      ..clear()
      ..addAll(value);
  }

  /// Removes every node from [children].
  void clearChildren() => children.clear();
}

@internal
@immutable
final class ImmutableRouteNode extends RouteNode {
  @override
  final YxRoute route;

  @override
  final Map<String, String> arguments;

  @override
  final Map<String, Object?> extra;

  @override
  final Iterable<ImmutableRouteNode> children;

  factory ImmutableRouteNode({
    required YxRoute route,
    required Map<String, String> arguments,
    required Map<String, Object?> extra,
    required Iterable<RouteNode> children,
  }) =>
      ImmutableRouteNode._(
        route: route,
        arguments: RouteNodeUtil.immutableArguments(arguments),
        extra: RouteNodeUtil.immutableExtra(extra),
        children: RouteNodeUtil.immutableRouteNodes(children),
      );

  factory ImmutableRouteNode.fromRoute(
    YxRoute route, {
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
    List<RouteNode>? children,
  }) =>
      ImmutableRouteNode(
        route: route,
        arguments: arguments ?? const <String, String>{},
        extra: extra ?? const <String, Object?>{},
        children: children ?? const <RouteNode>[],
      );

  factory ImmutableRouteNode.fromRouteNode(
    RouteNode routeNode,
  ) =>
      ImmutableRouteNode(
        route: routeNode.route,
        arguments: routeNode.arguments,
        extra: routeNode.extra,
        children: routeNode.children,
      );

  const ImmutableRouteNode._({
    required this.route,
    required this.arguments,
    required this.extra,
    required this.children,
  }) : super._();

  @override
  ImmutableRouteNode copyWith({
    YxRoute? route,
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
    Iterable<RouteNode>? children,
  }) =>
      ImmutableRouteNode(
        route: route ?? this.route,
        arguments: arguments ?? this.arguments,
        extra: extra ?? this.extra,
        children: children ?? this.children,
      );

  @override
  ImmutableRouteNode toImmutable() => this;

  @override
  MutableRouteNode toMutable() => MutableRouteNode(
        route: route,
        arguments: arguments,
        extra: extra,
        children: children,
      );

  @override
  void traverse(
    RouteNodeAction<ImmutableRouteNode> action, {
    RouteNodePredicate<ImmutableRouteNode>? predicate,
    bool recursive = true,
  }) =>
      RouteNodeUtil.traverse<ImmutableRouteNode>(
        this,
        action,
        predicate: predicate,
        recursive: recursive,
      );

  @override
  void traverseChildren(
    RouteNodeAction<ImmutableRouteNode> action, {
    RouteNodePredicate<ImmutableRouteNode>? predicate,
    bool recursive = true,
  }) =>
      RouteNodeUtil.traverseChildren<ImmutableRouteNode>(
        this,
        action,
        predicate: predicate,
        recursive: recursive,
      );

  @override
  ImmutableRouteNode? find(
    RouteNodePredicate<ImmutableRouteNode> predicate, {
    bool recursive = true,
  }) =>
      RouteNodeUtil.find<ImmutableRouteNode>(
        this,
        predicate,
        recursive: recursive,
      );

  @override
  ImmutableRouteNode? findByRoute(
    YxRoute route, {
    bool recursive = true,
  }) =>
      RouteNodeUtil.findByRoute<ImmutableRouteNode>(
        this,
        route,
        recursive: recursive,
      );
}
