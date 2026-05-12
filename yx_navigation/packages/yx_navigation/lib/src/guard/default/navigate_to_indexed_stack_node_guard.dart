import 'package:meta/meta.dart';

import '../../base/route.dart';
import '../../base/route_node.dart';
import '../../extensions/route_node_extensions.dart';
import '../guard_context.dart';
import '../guard_result.dart';
import '../route_node_guard.dart';

/// {@template navigate_to_indexed_stack_node_guard}
/// Keeps an IndexedStack parent node aligned with a fixed set of tab routes:
/// every declared route appears exactly once as a child, order may change
/// (for example when [ActiveRouteController] reorders tabs), and
/// `arguments`, `extra`, and nested child state on existing nodes are kept
/// when nodes are added or removed.
///
/// ## Behavior
///
/// When the guard runs against the IndexedStack node for its configured route:
/// 1. If that node is absent from the tree → [GuardResult.next].
/// 2. If the configured declared-route list is empty → [GuardResult.cancel].
/// 3. If children are missing, duplicated, or include undeclared routes →
///    [GuardResult.redirect] with a repaired child list.
/// 4. If the structure already matches the declaration → [GuardResult.next].
///
/// ## Invariants
///
/// **Shape**
/// - The node has exactly one child per declared route (same cardinality as
///   the declaration).
/// - Every child route appears in the declared set; **extra** child routes are
///   not allowed.
/// - Child order is unconstrained so tab reordering stays valid.
///
/// **Preservation**
/// - For routes that remain before and after the fix, [RouteNode.arguments],
///   [RouteNode.extra], and deeper navigation state under those nodes are
///   retained where possible.
///
/// ## Example
///
/// ```dart
/// const guard = NavigateToIndexedStackNodeGuard(
///   route: Routes.tabBar,
///   declaredRoutes: [Routes.home, Routes.profile, Routes.settings],
/// );
///
/// // If tabBar has only home and profile, the guard adds settings.
/// // If tabBar has home, an undeclared route, and profile, the guard removes
/// // the undeclared branch while preserving arguments/extra on the rest.
/// ```
/// {@endtemplate}
@immutable
class NavigateToIndexedStackNodeGuard implements RouteNodeGuard {
  final YxRoute _route;
  final Iterable<YxRoute> _declaredRoutes;

  /// {@macro navigate_to_indexed_stack_node_guard}
  const NavigateToIndexedStackNodeGuard({
    required YxRoute route,
    required Iterable<YxRoute> declaredRoutes,
  })  : _route = route,
        _declaredRoutes = declaredRoutes;

  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
  ) {
    final mutableTarget = target.toMutable();
    final observedNodes = <MutableRouteNode>[];
    mutableTarget.traverse(
      (node) {
        observedNodes.add(node);
        return true;
      },
      predicate: (node) => node.route == _route,
    );
    if (observedNodes.isEmpty) {
      return const GuardResult.next();
    }

    if (_declaredRoutes.isEmpty) {
      return const GuardResult.cancel(reason: 'Declared routes are empty');
    }

    bool isTargetNodeChanged = false;
    for (final observedNode in observedNodes) {
      if (!_isIndexedStackNodeValid(routeNode: observedNode)) {
        _initializeRouteNode(observedNode);
        isTargetNodeChanged = true;
      }
    }
    return isTargetNodeChanged
        ? GuardResult.redirect(target: mutableTarget)
        : const GuardResult.next();
  }

  /// Initializes or updates the route node's children structure.
  ///
  /// This method:
  /// 1. Preserves existing nodes that are in [_declaredRoutes]
  /// 2. Removes nodes that are not in [_declaredRoutes]
  /// 3. Adds missing nodes from [_declaredRoutes]
  /// 4. Maintains [arguments] and [extra] data of existing nodes
  ///
  /// The order of children follows the order of existing valid children,
  /// with new children added at the end.
  void _initializeRouteNode(
    MutableRouteNode observedNode,
  ) {
    final declaredRoutes = _declaredRoutes.toSet();
    final existingValidRoutes = <YxRoute>{};

    final validChildren = <MutableRouteNode>[];
    for (final node in observedNode.children) {
      if (declaredRoutes.contains(node.route)) {
        existingValidRoutes.add(node.route);
        validChildren.add(node);
      }
    }

    // Add missing nodes from declaredRoutes
    for (final route in _declaredRoutes) {
      if (!existingValidRoutes.contains(route)) {
        validChildren.add(route.toNode().toMutable());
      }
    }

    observedNode.setChildren(validChildren);
  }

  /// Validates if the indexed stack node structure is correct.
  ///
  /// A node is considered valid when:
  /// - It has at least as many children as [_declaredRoutes]
  /// - All routes from [_declaredRoutes] are present
  /// - Any order of declared routes is allowed (supports reordering in ActiveRouteController)
  /// - Extra routes are not permitted
  ///
  /// Returns `true` if the node structure is valid, `false` otherwise.
  bool _isIndexedStackNodeValid({
    required MutableRouteNode routeNode,
  }) {
    final currentRoutes = routeNode.children.map((e) => e.route).toList();
    if (currentRoutes.isEmpty) {
      return false;
    }

    // Check that there are at least as many children as declared routes
    if (currentRoutes.length != _declaredRoutes.length) {
      return false;
    }

    // Check that all declared routes are present
    final declaredRoutesSet = _declaredRoutes.toSet();
    final currentRoutesSet = currentRoutes.toSet();

    if (!currentRoutesSet.containsAll(declaredRoutesSet)) {
      return false;
    }

    return true;
  }
}
