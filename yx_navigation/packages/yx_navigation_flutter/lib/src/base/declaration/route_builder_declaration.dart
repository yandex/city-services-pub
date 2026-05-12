import 'package:meta/meta.dart';

import 'route_declaration.dart';

/// {@template route_builder_declaration}
/// Flexible route declaration that allows any child route to be added at
/// runtime.
///
/// This declaration does not validate the hierarchy of child routes — any
/// route can be pushed as a child. The [BaseRouteDeclaration.declarations]
/// list documents the expected children but is not enforced.
///
/// **For production-ready features with validated navigation paths**,
/// consider using [RouteDeclaration.strict] instead, which enforces that
/// only declared child routes can be navigated to.
///
/// Works with any [RouteBuilder]:
/// - [RouteBuilder.widget] — simple pages without nested navigation.
/// - [RouteBuilder.outlet] — nested Navigator with stack navigation.
/// - [RouteBuilder.indexed] — `IndexedStack` for custom tab logic.
///
/// Example:
/// ```dart
/// RouteDeclaration.routeBuilder(
///   route: AppRoutes.home,
///   routeBuilder: RouteBuilder.widget(
///     builder: (context, node) => HomePage(),
///   ),
///   declarations: [
///     settingsDeclaration, // Documented but not enforced.
///     profileDeclaration,  // Documented but not enforced.
///   ],
/// );
///
/// // Any route can be pushed, even if not in declarations:
/// navigator.push(AppRoutes.anyOtherRoute); // ✅ Allowed
/// ```
///
/// See also:
/// * [RouteDeclaration.strict] — for enforced hierarchy validation.
/// * [RouteStrictDeclaration] — the implementation of strict validation.
/// {@endtemplate}
@immutable
class RouteBuilderDeclaration extends BaseRouteDeclaration {
  /// {@macro route_builder_declaration}
  RouteBuilderDeclaration({
    required super.route,
    required super.routeBuilder,
    super.declarations,
    super.guards,
    super.deeplinkHandlers,
    super.deeplinkStrategy,
    super.observer,
  });
}
