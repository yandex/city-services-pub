import 'package:meta/meta.dart';

import '../../base/route.dart';
import '../../base/route_node.dart';
import '../guard_context.dart';
import '../guard_result.dart';
import '../route_node_guard.dart';

typedef InitialRouteNodeBuilder = RouteNode Function(MutableRouteNode node);

@immutable
class InitializeSchemaNodeGuard implements RouteNodeGuard {
  final YxRoute _route;
  final InitialRouteNodeBuilder _builder;

  const InitializeSchemaNodeGuard({
    required YxRoute route,
    required InitialRouteNodeBuilder builder,
  })  : _route = route,
        _builder = builder;

  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
  ) {
    final mutableTarget = target.toMutable();
    final routeNodes = <MutableRouteNode>[];
    mutableTarget.traverse(
      (node) {
        routeNodes.add(node);
        return false;
      },
      predicate: (node) => node.route == _route && !node.hasChildren,
    );

    if (routeNodes.isEmpty) {
      return const GuardResult.next();
    }

    for (final routeNode in routeNodes) {
      try {
        _initializeRouteNode(routeNode);
      } on NotValidSchemeRouteNodeException {
        return const GuardResult.cancel();
      }
    }

    return GuardResult.redirect(target: mutableTarget);
  }

  void _initializeRouteNode(MutableRouteNode routeNode) {
    if (routeNode.hasChildren) {
      return;
    }

    final result = _builder.call(routeNode.copyWith());
    routeNode
      ..setArguments(result.arguments)
      ..setExtra(result.extra)
      ..setChildren(result.children);

    if (!routeNode.hasChildren) {
      throw const NotValidSchemeRouteNodeException();
    }
  }
}

@immutable
class NotValidSchemeRouteNodeException implements Exception {
  const NotValidSchemeRouteNodeException();
}
