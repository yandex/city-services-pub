import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/router/router_schema.dart';

YxRoute makeRoute({String id = 'route'}) => YxRoute(id: id);

RouteNode makeNode({
  YxRoute? route,
  Map<String, String> arguments = const <String, String>{},
  Map<String, Object?> extra = const <String, Object?>{},
  List<RouteNode> children = const <RouteNode>[],
}) =>
    RouteNode.fromRoute(
      route: route ?? makeRoute(),
      arguments: arguments,
      extra: extra,
      children: children,
    );

RouteNode makeImmutableNode({
  required YxRoute route,
  Map<String, String> arguments = const <String, String>{},
  Map<String, Object?> extra = const <String, Object?>{},
  List<RouteNode> children = const <RouteNode>[],
}) =>
    RouteNode.immutable(
      route: route,
      arguments: arguments,
      extra: extra,
      children: children,
    );

RouteNode makeMutableNode({
  required YxRoute route,
  Map<String, String> arguments = const <String, String>{},
  Map<String, Object?> extra = const <String, Object?>{},
  List<RouteNode> children = const <RouteNode>[],
}) =>
    RouteNode.mutable(
      route: route,
      arguments: arguments,
      extra: extra,
      children: children,
    );

RouteNodeStateManager makeStateManager({
  RouteNode? root,
  RouteNodeGuard? routeNodeGuard,
  GuardSync? guardSync,
}) =>
    RouteNodeStateManager(
      routeNode: root ?? makeNode(route: makeRoute(id: 'root')),
      routeNodeGuard: routeNodeGuard,
      guardSync: guardSync,
    );

GuardConfiguration makeGuardConfig({List<RouteNodeGuard>? guards}) =>
    GuardConfiguration(guards: guards ?? const <RouteNodeGuard>[]);

RouterSchema makeSchema({
  required InitialRouteNodeBuilder initialNodeBuilder,
  List<RouteDeclaration> declarations = const <RouteDeclaration>[],
  List<DeeplinkHandler> deeplinkHandlers = const <DeeplinkHandler>[],
  DeeplinkHandlerStrategy deeplinkStrategy = const DeeplinkHandlerStrategy.fifo(),
}) =>
    _TestSchema(
      builder: initialNodeBuilder,
      declarations: declarations,
      deeplinkHandlers: deeplinkHandlers,
      deeplinkStrategy: deeplinkStrategy,
    );

class _TestSchema extends RouterSchema {
  final InitialRouteNodeBuilder builder;

  @override
  final Iterable<RouteDeclaration> declarations;

  @override
  final Iterable<DeeplinkHandler> deeplinkHandlers;

  @override
  final DeeplinkHandlerStrategy deeplinkStrategy;

  _TestSchema({
    required this.builder,
    required this.declarations,
    required this.deeplinkHandlers,
    required this.deeplinkStrategy,
  });

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) => builder(node);
}
