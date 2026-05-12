import 'package:meta/meta.dart';

import '../../base/route.dart';
import '../../base/route_node.dart';
import '../guard_context.dart';
import '../guard_result.dart';
import '../route_node_guard.dart';

/// {@template strict_hierarchy_guard}
/// Validates that children of a given parent route stay within an explicit
/// allow-list of child routes.
///
/// When you use `RouteDeclaration.strict` from `package:yx_navigation_flutter`,
/// this guard is registered for you on that declaration. **Strict** means:
/// every child route under the guarded parent must appear in the declaration's
/// `declarations` list—navigation to any other child route is rejected.
///
/// The guard only inspects the subtree rooted at the parent route it was built
/// for; other branches of the tree are unchanged.
///
/// ## Behavior
///
/// On each navigation operation the guard:
/// 1. Locates the parent node whose route matches the guarded parent route.
/// 2. Checks every direct child: its route must be one of the allowed routes.
/// 3. Throws [StateError] if any child violates the allow-list (in both debug
///    and release builds).
///
/// ## Example
///
/// ```dart
/// // StrictHierarchyGuard is wired automatically for this constructor.
/// RouteDeclaration.strict(
///   route: AppRoutes.profile,
///   declarations: [settingsDeclaration, privacyDeclaration],
/// )
/// ```
/// {@endtemplate}
@immutable
class StrictHierarchyGuard implements RouteNodeGuard {
  final YxRoute _route;
  final Iterable<YxRoute> _declaredRoutes;

  /// {@macro strict_hierarchy_guard}
  const StrictHierarchyGuard({
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
    _validateNodeTree(target);
    return const GuardResult.next();
  }

  void _validateNodeTree(RouteNode targetNode) {
    targetNode.traverse(
      (node) {
        for (final child in node.children) {
          if (!_declaredRoutes.contains(child.route)) {
            throw StateError(
              'Hierarchy validation failed:\n'
              'Route "${child.route.id}" is not declared in '
              'parent route "${_route.id}" declarations.\n'
              'Declared children: ${_declaredRoutes.map((r) => r.id).join(", ")}\n'
              'Attempted to navigate to: ${child.route.id}\n\n'
              'To fix: Add "${child.route.id}" to declarations of "${_route.id}", '
              'or use RouteDeclaration.routeBuilder() instead of RouteDeclaration.strict()',
            );
          }
        }
        return false;
      },
      predicate: (node) => node.route == _route,
    );
  }
}
