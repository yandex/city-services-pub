import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'declaration/route_declaration.dart';

/// {@template route_declaration_resolver}
/// Resolves the [RouteDeclaration] that corresponds to a given [RouteNode].
///
/// The resolver flattens a tree of declarations into a lookup table keyed by
/// [YxRoute]. It is used by the router delegate and debug tooling to find the
/// declaration that should render a given node.
/// {@endtemplate}
class RouteDeclarationResolver {
  /// Flattened map of declarations keyed by their [YxRoute].
  final Map<YxRoute, RouteDeclaration> _declarations;

  /// {@macro route_declaration_resolver}
  RouteDeclarationResolver({
    required Iterable<RouteDeclaration> declarations,
  }) : _declarations = buildDeclarationsMap({}, declarations);

  /// Flattened map of declarations keyed by their [YxRoute].
  @protected
  Map<YxRoute, RouteDeclaration> get declarations => _declarations;

  /// Returns the declaration registered for [routeNode], or `null` if none
  /// matches the node's route.
  RouteDeclaration? resolve(RouteNode routeNode) {
    final declaration = declarations[routeNode.route];
    return declaration;
  }

  @protected
  @internal
  static Map<YxRoute, RouteDeclaration> buildDeclarationsMap(
    Map<YxRoute, RouteDeclaration> map,
    Iterable<RouteDeclaration> declarations,
  ) {
    for (final currentDeclaration in declarations) {
      assert(
        !map.containsKey(currentDeclaration.route),
        'Map does already contain route ${currentDeclaration.route} ',
      );

      map[currentDeclaration.route] = currentDeclaration;
      map.addAll(buildDeclarationsMap(map, currentDeclaration.declarations));
    }

    return map;
  }
}
