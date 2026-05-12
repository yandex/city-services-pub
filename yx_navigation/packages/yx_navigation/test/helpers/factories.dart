import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/guard/guard_configuration.dart';
import 'package:yx_navigation/src/guard/guard_sync.dart';
import 'package:yx_navigation/src/guard/route_node_guard.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

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
