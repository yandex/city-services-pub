import '../route_node.dart';

/// {@template route_node_comparator}
/// Comparison helpers for [RouteNode] instances.
///
/// The class is not meant to be instantiated. Use its static members
/// as [Comparator] callbacks, for example when sorting node lists.
/// {@endtemplate}
abstract final class RouteNodeComparator {
  /// Compares two nodes by their [RouteNode.route] identity.
  ///
  /// Returns a negative value if [nodeA]'s route sorts before [nodeB]'s,
  /// zero if they are equal, and a positive value otherwise.
  static int compareByRoute(
    RouteNode nodeA,
    RouteNode nodeB,
  ) =>
      nodeA.route.compareTo(nodeB.route);
}
