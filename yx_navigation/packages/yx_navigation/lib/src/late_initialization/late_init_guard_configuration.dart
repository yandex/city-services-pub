import 'package:meta/meta.dart';

import '../../yx_navigation.dart';

/// {@template late_init_route_node_guard}
/// A [RouteNodeGuard] whose contributing guards are registered after
/// construction.
///
/// Groups of guards are attached and detached by logical [name] (typically a
/// feature or module identifier), which lets each module own its own
/// lifecycle without mutating a shared list directly.
/// {@endtemplate}
abstract interface class LateInitRouteNodeGuard implements RouteNodeGuard {
  /// {@macro late_init_route_node_guard}
  const LateInitRouteNodeGuard();

  /// Attaches [values] to the guard pipeline under the given [name].
  void attach(String name, Iterable<RouteNodeGuard> values);

  /// Detaches the guards previously attached under [name].
  void detach(String name);
}

/// {@template late_init_guard_configuration}
/// A [GuardConfiguration] that accepts additional guards after construction.
///
/// Feature modules can call [attach] to contribute their own guards and
/// [detach] to remove them when the module unloads. The effective list
/// returned from [guards] is the base list passed to the constructor
/// followed by every attached group.
/// {@endtemplate}
@experimental
final class LateInitGuardConfiguration extends GuardConfiguration
    implements LateInitRouteNodeGuard {
  /// Attached guard groups, keyed by module name.
  final Map<String, Iterable<RouteNodeGuard>> _values = {};

  /// Cached result of combining base and attached guards.
  Iterable<RouteNodeGuard>? _cachedGuards;

  /// {@macro late_init_guard_configuration}
  ///
  /// [guards] are the base guards passed to [GuardConfiguration].
  /// [redirectGuard] is an optional guard that detects redirect loops.
  /// [observer] receives guard pipeline events.
  LateInitGuardConfiguration({
    super.guards = const [],
    super.redirectGuard,
    super.observer,
  });

  @override
  Iterable<RouteNodeGuard> get guards {
    final cached = _cachedGuards;
    if (cached != null) {
      return cached;
    }

    final baseGuards = super.guards;
    if (_values.isEmpty) {
      return _cachedGuards = baseGuards;
    }

    final combinedGuards = <RouteNodeGuard>[
      ...baseGuards,
      for (final guards in _values.values) ...guards,
    ];

    return _cachedGuards = List<RouteNodeGuard>.unmodifiable(combinedGuards);
  }

  /// Attaches guards to the route node.
  ///
  /// Attaches guards from the module with the specified name to the common
  /// configuration. Guards will be combined with base guards on the next
  /// access to [guards].
  ///
  /// [name] - The name of the navigation module from which guards are attached
  /// [values] - An iterable collection of guards to attach
  ///
  /// Throws [StateError] if guards with this name are already attached.
  @override
  void attach(String name, Iterable<RouteNodeGuard> values) {
    if (_values.containsKey(name)) {
      throw StateError('Guards for "$name" are already attached');
    }
    _values[name] = values;
    _cachedGuards = null;
  }

  /// Detaches guards from the route node.
  ///
  /// Removes previously attached guards from the module with the specified name.
  /// Guards will be excluded from the common configuration on the next
  /// access to [guards].
  ///
  /// [name] - The name of the navigation module from which guards are detached
  ///
  /// Throws [StateError] if guards with this name were not attached.
  @override
  void detach(String name) {
    if (!_values.containsKey(name)) {
      throw StateError('Guards for "$name" were not attached');
    }
    _values.remove(name);
    _cachedGuards = null; // Cache invalidation
  }
}
