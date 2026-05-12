import 'package:yx_navigation/yx_navigation.dart';

import '../builder/route_indexed_stack_builder.dart';
import 'route_declaration.dart';

/// {@template route_indexed_declaration}
/// Simplified declaration for `IndexedStack`-based tab implementations.
///
/// Automatically manages tab children through guards, eliminating the need
/// for manual `RouteNode.children` configuration. Designed for standard
/// tab scenarios with static tab lists.
///
/// **Automatic guards.** Adds a `NavigateToIndexedStackNodeGuard` that
/// ensures all declared routes are present as children in the route node,
/// automatically adding missing ones and removing undeclared ones.
///
/// **ActiveRouteController.** The `indexedBuilder` callback receives a
/// controller for managing which tab is currently active.
///
/// **State preservation.** Uses `IndexedStack` with `Offstage` and
/// `TickerMode` to preserve state of all tabs while only displaying the
/// active one.
///
/// **When to use:**
/// - Need static tabs (fixed list of tabs).
/// - Want automatic guards for children management.
/// - Need a `TabBar`, `BottomNavigationBar`, or `PageView`.
/// - Tab state preservation required.
///
/// **Limitations:**
/// - Only supports static tab lists (defined at declaration time).
/// - Cannot dynamically add/remove tabs at runtime.
/// - For dynamic tabs, use [RouteBuilderDeclaration] with
///   [RouteIndexedStackBuilder].
///
/// Example:
/// ```dart
/// RouteDeclaration.indexedStack(
///   route: AppRoutes.home,
///   routeBuilder: RouteBuilder.indexed(
///     indexedBuilder: (context, routeNode, indexedStack, controller) {
///       return Scaffold(
///         body: indexedStack,
///         bottomNavigationBar: BottomNavigationBar(
///           currentIndex: [AppRoutes.map, AppRoutes.messages]
///               .indexOf(controller.activeRoute!),
///           onTap: (i) => controller.setActiveRoute(
///             [AppRoutes.map, AppRoutes.messages][i],
///           ),
///           items: [/* ... */],
///         ),
///       );
///     },
///   ),
///   declarations: [
///     mapTabDeclaration,      // Auto-managed by guards.
///     messagesTabDeclaration, // Auto-managed by guards.
///   ],
/// );
/// ```
///
/// See also:
/// * `NavigateToIndexedStackNodeGuard` in `package:yx_navigation` — the
///   automatic guard used for indexed stacks.
/// * [ActiveRouteController] — for tab management.
/// * [RouteBuilderDeclaration] — for dynamic tabs.
/// {@endtemplate}
class RouteIndexedStackDeclaration extends BaseRouteDeclaration {
  /// {@macro route_indexed_declaration}
  RouteIndexedStackDeclaration({
    required super.route,
    required super.declarations,
    required RouteIndexedStackBuilder routeBuilder,
    Iterable<RouteNodeGuard> guards = const [],
    super.deeplinkHandlers = const [],
    super.deeplinkStrategy = const DeeplinkHandlerStrategy.fifo(),
    super.observer,
  }) : super(
          routeBuilder: routeBuilder,
          guards: [
            ...guards,
            NavigateToIndexedStackNodeGuard(
              route: route,
              declaredRoutes: declarations.map((e) => e.route).toList(),
            )
          ],

        );
}
