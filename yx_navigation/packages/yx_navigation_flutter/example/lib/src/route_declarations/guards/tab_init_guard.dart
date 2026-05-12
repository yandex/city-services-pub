import 'package:yx_navigation/yx_navigation.dart';

/// Generic guard that initializes a tab with its first child node.
///
/// Automatically adds [childRoute] under [tabRoute] whenever the tab
/// has no children.
///
/// Useful so that the first time a user opens a tab with nested navigation
/// a default screen is shown instead of a blank page.
///
/// Example:
/// ```dart
/// final messagesTabDeclaration = RouteDeclaration.routeBuilder(
///   route: AppRoutes.messagesTab,
///   guards: [
///     TabInitGuard(
///       tabRoute: AppRoutes.messagesTab,
///       childRoute: AppRoutes.chatList,
///     ),
///   ],
///   routeBuilder: RouteBuilder.outlet(...),
///   declarations: [...],
/// );
/// ```
class TabInitGuard implements RouteNodeGuard {
  /// Tab route to initialize.
  final YxRoute tabRoute;

  /// Initial child route for the tab.
  final YxRoute childRoute;

  const TabInitGuard({
    required this.tabRoute,
    required this.childRoute,
  });

  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
  ) {
    final mutableTarget = target.toMutable();

    // Locate the tab node.
    final tabNode = mutableTarget.findByRoute(tabRoute);

    // If the tab exists and has no children, add the initial one.
    if (tabNode != null && tabNode.children.isEmpty) {
      tabNode.setChildren([
        childRoute.toNode(),
      ]);

      return GuardResult.redirect(target: mutableTarget);
    }

    return const GuardResult.next();
  }
}
