import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../route_node.dart';

/// {@template route_node_equality}
/// Strategy for comparing two [RouteNode] instances for equality.
///
/// Different strategies include or exclude certain fields ([RouteNode.route],
/// [RouteNode.arguments], [RouteNode.extra], [RouteNode.children]).
/// Pick the narrowest strategy that still reflects the equality you need.
///
/// ### Example
/// ```dart
/// const equality = RouteNodeEquality.routeAndArguments();
/// final same = equality.equals(nodeA, nodeB);
/// ```
/// {@endtemplate}
@experimental
sealed class RouteNodeEquality implements Equality<RouteNode> {
  const RouteNodeEquality._();

  /// Compares nodes by [RouteNode.route] only.
  const factory RouteNodeEquality.route() = ByRouteEquality;

  /// Compares nodes by [RouteNode.route] and [RouteNode.arguments].
  const factory RouteNodeEquality.routeAndArguments() =
      RouteAndArgumentsEquality;

  /// Compares nodes by [RouteNode.route], [RouteNode.arguments]
  /// and [RouteNode.extra].
  const factory RouteNodeEquality.routeAndArgumentsAndExtra() =
      RouteAndArgumentsAndExtraEquality;

  /// Compares nodes by [RouteNode.route], [RouteNode.arguments],
  /// [RouteNode.extra] and [RouteNode.children], recursively.
  const factory RouteNodeEquality.deep() = DeepRouteNodeEquality;
}

/// Equality that compares [RouteNode]s by [RouteNode.route] only.
@immutable
class ByRouteEquality extends RouteNodeEquality {
  /// Creates a [ByRouteEquality].
  const ByRouteEquality() : super._();

  @override
  bool equals(RouteNode a, RouteNode b) =>
      identical(a, b) || a.route == b.route;

  @override
  int hash(RouteNode node) => node.route.hashCode;

  @override
  bool isValidKey(Object? o) => o is RouteNode;
}

/// Equality that compares [RouteNode]s by both [RouteNode.route]
/// and [RouteNode.arguments].
@immutable
class RouteAndArgumentsEquality extends RouteNodeEquality {
  /// Creates a [RouteAndArgumentsEquality].
  const RouteAndArgumentsEquality() : super._();

  @override
  bool equals(RouteNode a, RouteNode b) =>
      identical(a, b) ||
      (const ByRouteEquality().equals(a, b) &&
          const MapEquality().equals(a.arguments, b.arguments));

  @override
  int hash(RouteNode node) => Object.hash(
        const ByRouteEquality().hash(node),
        const MapEquality().hash(node.arguments),
      );

  @override
  bool isValidKey(Object? o) => o is RouteNode;
}

/// Equality that compares [RouteNode]s by [RouteNode.route],
/// [RouteNode.arguments] and [RouteNode.extra].
@immutable
class RouteAndArgumentsAndExtraEquality extends RouteNodeEquality {
  /// Creates a [RouteAndArgumentsAndExtraEquality].
  const RouteAndArgumentsAndExtraEquality() : super._();

  @override
  bool equals(RouteNode a, RouteNode b) =>
      identical(a, b) ||
      (const RouteAndArgumentsEquality().equals(a, b) &&
          const DeepCollectionEquality().equals(a.extra, b.extra));

  @override
  int hash(RouteNode node) => Object.hash(
        const RouteAndArgumentsEquality().hash(node),
        const DeepCollectionEquality().hash(node.extra),
      );

  @override
  bool isValidKey(Object? o) => o is RouteNode;
}

/// Equality that recursively compares [RouteNode]s including their
/// [RouteNode.children].
@immutable
class DeepRouteNodeEquality extends RouteNodeEquality {
  /// Creates a [DeepRouteNodeEquality].
  const DeepRouteNodeEquality() : super._();

  @override
  bool equals(RouteNode a, RouteNode b) =>
      identical(a, b) ||
      (const RouteAndArgumentsAndExtraEquality().equals(a, b) &&
          const IterableEquality<RouteNode>(DeepRouteNodeEquality()).equals(
            a.children,
            b.children,
          ));

  @override
  int hash(RouteNode node) => Object.hash(
        const RouteAndArgumentsAndExtraEquality().hash(node),
        const IterableEquality(DeepRouteNodeEquality()).hash(node.children),
      );

  @override
  bool isValidKey(Object? o) => o is RouteNode;
}
