import 'package:meta/meta.dart';

import '../base/route.dart';
import '../base/route_node.dart';

/// This is a helper class to
/// serialize and deserialize [RouteNode] to and from a JSON map.
///
/// This is a step in the [UriSerializer] serialization process.
@internal
abstract class RouteNodeSerializationTools {
  @visibleForTesting
  static const argumentsKey = 'args';

  @visibleForTesting
  static const childrenKey = 'c';

  @visibleForTesting
  static const routeKey = 'rt';

  static ImmutableRouteNode fromJson(Map<String, Object?> json) {
    final routeData = json[routeKey] as Map<String, Object?>?;

    if (routeData == null) {
      throw const FormatException('Trying to deserialize a node with no route');
    }

    final argumentsData = json[argumentsKey];
    final Map<String, String> castArguments;
    if (argumentsData == null) {
      castArguments = const <String, String>{};
    } else if (argumentsData is! Map) {
      throw FormatException(
        'Trying to deserialize a node with invalid arguments type: '
        'expected Map, got ${argumentsData.runtimeType}',
      );
    } else {
      final arguments = argumentsData as Map<String, Object?>;
      // Validate that all values are strings
      for (final entry in arguments.entries) {
        if (entry.value is! String) {
          throw FormatException(
            'Trying to deserialize a node with invalid argument value type: '
            'key "${entry.key}" has value of type ${entry.value.runtimeType}, '
            'expected String',
          );
        }
      }
      castArguments = arguments.cast<String, String>();
    }

    final route = YxRoute.fromJson(routeData);

    final children = <ImmutableRouteNode>[];
    final childrenData =
        (json[childrenKey] ?? const <Object?>[]) as List<Object?>;

    for (final childData in childrenData.nonNulls) {
      final mapData = childData as Map<String, Object?>;
      final node = fromJson(mapData);

      children.add(node);
    }

    return ImmutableRouteNode(
      route: route,
      arguments: castArguments,
      children: children,
      extra: const {},
    );
  }

  static Map<String, Object?> toJson(RouteNode node) {
    final Map<String, Object?> json = {};

    // route
    final routeData = node.route.toJson();
    json[routeKey] = routeData;

    // arguments
    final argumentsData = node.arguments;
    if (argumentsData.isNotEmpty) {
      json[argumentsKey] = argumentsData;
    }

    // children
    final childrenData = <Map<String, Object?>>[];
    for (final child in node.children) {
      childrenData.add(toJson(child));
    }

    if (childrenData.isNotEmpty) {
      json[childrenKey] = childrenData;
    }

    return json;
  }
}
