import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../page_factory/page_factory.dart';
import '../../router/router_schema.dart';
import '../back_button_handler.dart';
import '../builder/route_outlet_builder.dart';
import 'route_declaration.dart';

/// {@template route_schema_declaration}
/// Specialised declaration for integrating feature modules as isolated
/// schemas.
///
/// Always creates a nested Navigator and provides complete state isolation
/// for the feature. Designed for modular architectures where features are
/// developed independently and can work both standalone and embedded.
///
/// **Automatic nested Navigator.** Always uses [RouteBuilder.outlet]
/// internally, creating a dedicated Navigator for the feature's schema.
///
/// **State isolation.** Creates an isolated [NavigationController] that can
/// only access its own branch of the navigation tree, preventing
/// interference with parent or sibling features.
///
/// **Schema inheritance.** Forwards the wrapped schema's
/// [RouterSchema.declarations], [RouterSchema.guards],
/// [RouterSchema.deeplinkHandlers] and [RouterSchema.deeplinkStrategy] to
/// the surrounding tree, plus an [InitializeSchemaNodeGuard] bound to
/// [RouterSchema.initialNodeBuilder].
///
/// **When to use:**
/// - Integrating a ready-made feature from another package.
/// - Need complete isolation of navigation state.
/// - Feature is developed by a separate team.
/// - Feature needs to be reused in different applications.
/// - Feature supports both standalone and embedded modes.
///
/// Example:
/// ```dart
/// // Feature module with its own schema.
/// class MapFeatureSchema extends RouterSchema {
///   @override
///   Iterable<RouteDeclaration> get declarations => [/* feature routes */];
///
///   @override
///   RouteNode initialNodeBuilder(MutableRouteNode node) => /* ... */;
/// }
///
/// // Integration in a host app.
/// RouteDeclaration.scheme(
///   route: AppRoutes.mapFeature,
///   schema: MapFeatureSchema(),
///   outletBuilder: (context, routeNode, outlet) {
///     return MapFeatureDependenciesScope(
///       api: parentApi,
///       child: outlet, // Nested Navigator.
///     );
///   },
/// );
/// ```
///
/// See also:
/// * [RouterSchema] — the schema interface.
/// * [NavigationController] — for state isolation.
/// * [RouteBuilderDeclaration] — for non-isolated nested navigation.
/// {@endtemplate}
class RouteSchemaDeclaration extends BaseRouteDeclaration {
  /// {@macro route_schema_declaration}
  RouteSchemaDeclaration({
    required super.route,
    required RouterSchema schema,
    PageFactory? pageFactory,
    RouteNodeOutletBuilder? outletBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    TransitionDelegate<Object?>? transitionDelegate,
    Iterable<NavigatorObserver>? navigatorObservers,
    BackButtonHandler? backButtonHandler,
    String? restorationScopeId,
    NavigationController? navigationController,
    Iterable<RouteNodeGuard> guards = const [],
    super.observer,
  }) : super(
          declarations: schema.declarations,
          guards: [
            ...guards,
            ...schema.guards,
            InitializeSchemaNodeGuard(
              route: route,
              builder: schema.initialNodeBuilder,
            ),
          ],
          deeplinkHandlers: schema.deeplinkHandlers,
          deeplinkStrategy: schema.deeplinkStrategy,
          routeBuilder: RouteOutletBuilder(
            navigatorKey: navigatorKey,
            navigatorObservers: navigatorObservers,
            transitionDelegate: transitionDelegate,
            restorationScopeId: restorationScopeId,
            backButtonHandler: backButtonHandler,
            outletBuilder: outletBuilder,
            navigationController: navigationController,
            pageFactory: pageFactory,
          ),
        );
}
