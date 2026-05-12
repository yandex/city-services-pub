import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../state/base/closable.dart';
import '../state/base/route_node_readable.dart';
import '../state/resolve_state_manager.dart';
import '../state/state_manager.dart';
import 'active_route_controller.dart';
import 'route.dart';
import 'route_node.dart';
import 'route_node_resolver.dart';

/// {@template mutate_node_callback}
/// Callback that applies a mutation to a [MutableRouteNode] and returns
/// the resulting node.
///
/// The callback receives a mutable copy of the current tree. It can modify
/// children, arguments and extra data in place, then return the tree (or a
/// new one) that should become the next state.
/// {@endtemplate}
typedef MutateNodeCallback = RouteNode Function(
  MutableRouteNode routeNode,
);

/// {@template route_mutator}
/// Low level interface for applying arbitrary mutations to the route tree.
///
/// Most call sites should use the higher level [RouteNavigator] methods.
/// Use [mutate] only when the available helpers are not expressive enough.
/// {@endtemplate}
abstract class RouteMutator {
  /// Applies [callback] to the current tree and commits the returned node
  /// as the new state.
  RouteNode mutate(MutateNodeCallback callback);
}

/// {@template route_navigator}
/// High level navigation operations over the current route tree.
///
/// [RouteNavigator] exposes familiar push, pop and replace primitives, as
/// well as helpers to update a node's arguments, extra data and children.
/// {@endtemplate}
abstract class RouteNavigator {
  /// Pushes a new [route] onto the navigation stack.
  ///
  /// [route] - The [YxRoute] to be pushed onto the stack.
  /// [arguments] - An optional map of string key-value pairs, representing
  /// the arguments to be passed to the route.
  /// [extra] - An optional map of string keys and object values, representing
  /// any additional data to be associated with the route.
  void push(
    YxRoute route, {
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
  });

  /// Pushes a new [node] onto the navigation stack.
  ///
  /// [node] - The [RouteNode] to be pushed onto the stack.
  void pushNode(RouteNode node);

  /// Pushes multiple [routes] onto the navigation stack.
  ///
  /// Each element in the list includes a [YxRoute] along with its optional
  /// [arguments] and [extra] data.
  void pushAll(
    List<
            ({
              YxRoute route,
              Map<String, String>? arguments,
              Map<String, Object?>? extra,
            })>
        routes,
  );

  /// Replaces the current route with a new [route].
  ///
  /// [route] - The [YxRoute] to be pushed onto the stack.
  /// [arguments] - An optional map of string key-value pairs, representing
  /// the arguments to be passed to the route.
  /// [extra] - An optional map of string keys and object values, representing
  /// any additional data to be associated with the route.
  void pushReplacement(
    YxRoute route, {
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
  });

  /// Pushes a new [route] onto the stack and removes all routes until
  /// a [predicate] condition is met.
  ///
  /// [route] - The [YxRoute] to be pushed onto the stack.
  /// [predicate] - A function that determines which routes should be removed;
  ///  it returns true for routes that should remain.
  /// [arguments] - An optional map of string key-value pairs, representing
  /// the arguments to be passed to the route.
  /// [extra] - An optional map of string keys and object values, representing
  /// any additional data to be associated with the route.
  void pushAndRemoveUntil(
    YxRoute route,
    RouteNodePredicate<RouteNode> predicate, {
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
  });

  /// Determines if there are any routes that can be popped from the stack.
  ///
  /// Returns true if there are routes to pop, otherwise false.
  bool canPop();

  /// Remove the top route from the navigation stack.
  /// If there is only one route in the stack, nothing will happen.
  void maybePop();

  /// Remove one of the top routes from the navigation stack.
  /// If there is only one route in the stack, it throws a [StateError].
  void pop();

  /// Remove all routes from the navigation stack except for the first one.
  /// If there is only one route in the stack, nothing will happen.
  void popAll();

  /// Pops routes off the stack until a route satisfying
  /// the [predicate] is reached.
  ///
  /// This method only works at the current nesting level of elements.
  /// It successively removes elements from the top of the stack until
  /// a route satisfying [predicate] is reached.
  ///
  /// The last element is not removed to ensure the stack is never
  /// emptied by this operation.
  ///
  /// [predicate] - A function that determines which routes should not
  /// be popped;
  void popUntil(RouteNodePredicate<RouteNode> predicate);

  /// Removes a route from the stack if the route matches
  /// the [predicate] condition.
  ///
  /// This method operates only on the current nesting level of elements.
  /// It removes elements sequentially from the top of the stack
  /// and checks if the next element satisfies [predicate].
  ///
  /// The last remaining element matches [predicate]. In this case, the element
  /// is not removed to ensure the stack is never emptied by this operation.
  ///
  /// [predicate] - A function that determines which routes should be popped.
  void popWhere(RouteNodePredicate<RouteNode> predicate);

  /// Sets the [arguments] for the current route.
  ///
  /// [arguments] - A map of string key-value pairs, representing
  /// the new arguments to be associated with the current route.
  void setArguments(Map<String, String> arguments);

  /// Sets the [extra] data for the current route.
  ///
  /// [extra] - A map of string keys and object values, representing
  /// the new extra data to be associated with the current route.
  void setExtra(Map<String, Object?> extra);

  /// Sets the [children] for the current route.
  ///
  /// [children] - An iterable of [RouteNode] objects, representing
  /// the new children to be associated with the current route.
  void setChildren(Iterable<RouteNode> children);
}

/// {@template navigation_controller}
/// The main entry point for reading and changing the navigation tree.
///
/// [NavigationController] combines:
/// - [RouteNodeReadable] to read the current tree and subscribe to changes.
/// - [RouteNavigator] for high level push, pop and replace operations.
/// - [RouteMutator] for low level access via [RouteMutator.mutate].
/// - [ActiveRouteController] to track the currently active route.
/// - Closable behavior to release resources when the controller is no longer
///   needed.
/// {@endtemplate}
///
/// {@template parent_navigation_controller}
/// The [NavigationController] for the parent navigation scope (the outlet or
/// schema that owns this subtree).
///
/// Use it when a nested feature needs read access to the parent's route tree
/// or to coordinate navigation across scopes.
/// {@endtemplate}
abstract class NavigationController
    implements
        RouteNodeReadable,
        RouteMutator,
        RouteNavigator,
        ActiveRouteController,
        Closable {
  /// Creates a controller that operates on the node resolved by
  /// [nodeResolver] from the tree managed by [stateManager].
  factory NavigationController.node({
    required RouteNodeStateManager stateManager,
    required RouteNodeResolver nodeResolver,
  }) =>
      BaseResolveStateManager(
        controller: stateManager,
        routeNodeResolver: nodeResolver,
      );
}

@internal
abstract base class BaseRouteNavigator implements NavigationController {
  @override
  void push(
    YxRoute route, {
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
  }) =>
      mutate(
        (routeNode) {
          final value = RouteNode.fromRoute(
            route: route,
            arguments: arguments ?? const {},
            extra: extra ?? const {},
          );

          routeNode.add(value);
          return routeNode;
        },
      );

  @override
  void pushNode(RouteNode node) => mutate((routeNode) => routeNode..add(node));

  @override
  void pushAll(
    List<
            ({
              YxRoute route,
              Map<String, String>? arguments,
              Map<String, Object?>? extra,
            })>
        routes,
  ) =>
      mutate(
        (routeNode) {
          final routeNodes = routes.map(
            (value) => RouteNode.fromRoute(
              route: value.route,
              arguments: value.arguments ?? const {},
              extra: value.extra ?? const {},
            ),
          );

          routeNode.addAll(routeNodes);
          return routeNode;
        },
      );

  @override
  void pushReplacement(
    YxRoute route, {
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
  }) =>
      mutate(
        (routeNode) {
          final value = RouteNode.fromRoute(
            route: route,
            arguments: arguments ?? const {},
            extra: extra ?? const {},
          );

          routeNode.upsertLast(value);
          return routeNode;
        },
      );

  @override
  void pushAndRemoveUntil(
    YxRoute route,
    RouteNodePredicate<RouteNode> predicate, {
    Map<String, String>? arguments,
    Map<String, Object?>? extra,
  }) =>
      mutate(
        (routeNode) {
          final value = RouteNode.fromRoute(
            route: route,
            arguments: arguments ?? const {},
            extra: extra ?? const {},
          );

          routeNode
            ..removeUntil(predicate, recursive: false)
            ..add(value);
          return routeNode;
        },
      );

  @override
  bool canPop() {
    final value = state;

    if (value == null) {
      return false;
    }

    return value.children.length > 1;
  }

  @override
  void maybePop() => mutate(
        (routeNode) {
          if (routeNode.children.length < 2) {
            return routeNode;
          }

          routeNode.removeLast();
          return routeNode;
        },
      );

  @override
  void pop() => mutate(
        (routeNode) {
          if (routeNode.children.length < 2) {
            throw StateError('RouteNode cannot be popped');
          }

          routeNode.removeLast();
          return routeNode;
        },
      );

  @override
  void popAll() => mutate(
        (routeNode) {
          final first = routeNode.children.firstOrNull;

          if (first == null) {
            return routeNode;
          }

          return routeNode.copyWith(children: [first]);
        },
      );

  @override
  void popUntil(RouteNodePredicate<RouteNode> predicate) => mutate(
        (routeNode) {
          routeNode.removeUntil(
            (value) => predicate(value) || routeNode.children.length < 2,
            recursive: false,
          );
          return routeNode;
        },
      );

  @override
  void popWhere(RouteNodePredicate<RouteNode> predicate) => mutate(
        (routeNode) {
          routeNode.removeWhere(
            (value) => predicate(value) && routeNode.children.length > 1,
            recursive: false,
          );
          return routeNode;
        },
      );

  @override
  void setArguments(Map<String, String> arguments) => mutate(
        (routeNode) {
          routeNode.setArguments(arguments);
          return routeNode;
        },
      );

  @override
  void setExtra(Map<String, Object?> extra) => mutate(
        (routeNode) {
          routeNode.setExtra(extra);
          return routeNode;
        },
      );

  @override
  void setChildren(Iterable<RouteNode> children) => mutate(
        (routeNode) {
          routeNode.setChildren(children);
          return routeNode;
        },
      );

  @override
  bool isRouteActive(YxRoute route) => activeRoute == route;

  @override
  YxRoute? get activeRoute => state?.children.lastOrNull?.route;

  @override
  Stream<YxRoute?> get activeRouteStream =>
      stream.map((state) => state?.children.lastOrNull?.route).distinct();

  @override
  void setActiveRoute(YxRoute route) => mutate(
        (routeNode) {
          if (routeNode.children.isEmpty) {
            throw StateError(
              '$route cannot be set as active because '
              'the children list is empty',
            );
          }

          final value = routeNode.children.firstWhereOrNull(
            (element) => element.route == route,
          );
          if (value == null) {
            throw StateError(
              '$route cannot be set as active because '
              'there is no in the children list',
            );
          }

          routeNode.addOrMoveToEnd(value);
          return routeNode;
        },
      );
}
