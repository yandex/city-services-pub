import 'package:yx_navigation/yx_navigation.dart';

import 'route_builder_declaration.dart';

/// {@template route_strict_declaration}
/// A route declaration with strict hierarchy validation enabled.
///
/// Enforces that all child routes must be explicitly declared in the
/// `declarations` list. Attempting to navigate to an undeclared child
/// route triggers a [StrictHierarchyGuard] failure.
///
/// Example:
/// ```dart
/// RouteDeclaration.strict(
///   route: AppRoutes.profile,
///   routeBuilder: RouteBuilder.widget(
///     builder: (context, node) => ProfilePage(),
///   ),
///   declarations: [
///     // Only these routes are allowed as children.
///     settingsDeclaration,
///     privacyDeclaration,
///   ],
/// );
/// ```
///
/// See also:
/// * [RouteBuilderDeclaration] — for flexible navigation without strict
///   validation.
/// * [StrictHierarchyGuard] — the guard that performs the validation.
/// {@endtemplate}
class RouteStrictDeclaration extends RouteBuilderDeclaration {
  /// {@macro route_strict_declaration}
  RouteStrictDeclaration({
    required super.route,
    required super.routeBuilder,
    required super.declarations,
    Iterable<RouteNodeGuard> guards = const [],
    super.deeplinkHandlers = const [],
    super.deeplinkStrategy = const DeeplinkHandlerStrategy.fifo(),
    super.observer,
  }) : super(
          guards: [
            ...guards,
            StrictHierarchyGuard(
              route: route,
              declaredRoutes: declarations.map((e) => e.route).toList(),
            ),
          ],
        );
}
