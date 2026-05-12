import 'dart:async';

import 'package:meta/meta.dart';

import '../base/route_navigator.dart';
import '../base/route_node.dart';
import '../base/route_node_resolver.dart';

final class BaseResolveStateManager extends BaseRouteNavigator {
  final NavigationController _controller;
  final RouteNodeResolver _resolver;

  late final Stream<RouteNode?> _stream = _controller.stream
      .map((state) => state == null ? null : _resolver.resolve(state))
      .asBroadcastStream();

  @nonVirtual
  @override
  bool get isClosed => _controller.isClosed;

  @nonVirtual
  @override
  RouteNode? get state {
    final current = _controller.state;
    if (current == null) {
      return null;
    }
    return _resolver.resolve(current);
  }

  @nonVirtual
  @override
  Stream<RouteNode?> get stream => _stream;

  BaseResolveStateManager({
    required NavigationController controller,
    required RouteNodeResolver routeNodeResolver,
  })  : _controller = controller,
        _resolver = routeNodeResolver;

  @mustCallSuper
  @override
  Future<void> close() => Future<void>.value();

  @override
  RouteNode mutate(MutateNodeCallback callback) => _controller.mutate(
        (routeNode) {
          final resolvedNode = _resolver.resolve(routeNode)?.toMutable();

          if (resolvedNode == null) {
            throw StateError('Resolved node is null');
          }

          final toCallback = resolvedNode.copyWith();
          final next = callback(toCallback);

          resolvedNode
            ..setArguments(next.arguments)
            ..setExtra(next.extra)
            ..setChildren(next.children);

          return routeNode;
        },
      );
}
