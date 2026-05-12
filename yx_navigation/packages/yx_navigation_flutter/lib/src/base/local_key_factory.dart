import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// Factory for [LocalKey] for [Page] of this route using [RouteNode].
@internal
@immutable
class LocalKeyFactory {
  const LocalKeyFactory();

  /// Create [LocalKey] for [Page] of this route using [RouteNode].
  LocalKey createKey(RouteNode routeNode) {
    final route = routeNode.route;
    final arguments = routeNode.arguments;

    if (routeNode.arguments.isEmpty) {
      return ValueKey<String>(route.id);
    }

    final value = arguments.entries.map((e) => '${e.key}=${e.value}').join(';');
    return ValueKey('${route.id}#$value');
  }
}
