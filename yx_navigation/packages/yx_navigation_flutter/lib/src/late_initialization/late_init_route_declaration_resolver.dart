import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';


import '../base/declaration/route_declaration.dart';
import '../base/route_declaration_resolver.dart';

/// {@template late_init_route_declaration_resolver}
/// Resolver that combines an initial set of [RouteDeclaration]s with
/// declarations supplied later by feature modules.
///
/// Modules call [attach] to register their declarations under a unique
/// name after the schema has been initialised, and [detach] to remove
/// them again. Use this resolver when the full route table is not known
/// at schema-construction time (for example, when a module ships its
/// own routes loaded dynamically).
/// {@endtemplate}
class LateInitRouteDeclarationResolver extends RouteDeclarationResolver {
  /// Declarations attached at runtime, keyed by module name.
  final Map<String, Map<YxRoute, RouteDeclaration>> _values = {};

  /// Cached merge of initial and attached declarations.
  Map<YxRoute, RouteDeclaration>? _cachedDeclarations;

  /// {@macro late_init_route_declaration_resolver}
  LateInitRouteDeclarationResolver({
    super.declarations = const [],
  });

  @mustCallSuper
  @override
  Map<YxRoute, RouteDeclaration> get declarations {
    final cached = _cachedDeclarations;

    if (cached != null) {
      return cached;
    }

    return _cachedDeclarations = _makeDeclarations(super.declarations);
  }

  /// Attaches [values] to the resolver under the module name [name].
  ///
  /// The declarations are merged with the initial ones on the next read
  /// from [declarations].
  ///
  /// Throws a [StateError] if a module with [name] has already been
  /// attached. In debug mode, also asserts that [values] does not contain
  /// any [YxRoute] keys that already exist in the merged declaration map.
  void attach(String name, Iterable<RouteDeclaration> values) {
    if (_values.containsKey(name)) {
      throw StateError('Declarations for "$name" are already attached');
    }

    final declarations = RouteDeclarationResolver.buildDeclarationsMap(
      <YxRoute, RouteDeclaration>{},
      values,
    );

    assert(
      () {
        final intersectionKeys = _getIntersectionRouteKeys(declarations);
        return intersectionKeys.isEmpty;
      }(),
      'You are trying to attach some declarations that already exist in '
      'source declarations list\n '
      'Intersection keys are: ${_getIntersectionRouteKeys(declarations)}',
    );

    _values[name] = declarations;
    _cachedDeclarations = null; // Cache invalidation
  }

  /// Detaches declarations previously registered under the module name [name].
  ///
  /// The declarations are removed from the merged declaration map on the
  /// next read from [declarations].
  ///
  /// Throws a [StateError] if no module with [name] was attached.
  void detach(String name) {
    if (!_values.containsKey(name)) {
      throw StateError('Declarations for "$name" were not attached');
    }

    _values.remove(name);
    _cachedDeclarations = null; // Cache invalidation
  }

  Set<YxRoute> _getIntersectionRouteKeys(
    Map<YxRoute, RouteDeclaration> values,
  ) {
    final sourceKeys = values.keys.toSet();
    final intersectionKeys = declarations.keys.toSet().intersection(sourceKeys);
    return intersectionKeys;
  }

  /// Returns a fresh map merging the initial declarations with every
  /// attached module's declarations.
  Map<YxRoute, RouteDeclaration> _makeDeclarations(
    Map<YxRoute, RouteDeclaration> initial,
  ) {
    final current = Map<YxRoute, RouteDeclaration>.of(initial);
    for (final entry in _values.entries) {
      current.addAll(entry.value);
    }
    return current;
  }
}
