import 'package:meta/meta.dart';

/// {@template guard_context}
/// A shared scratch space passed through the guard pipeline.
///
/// [GuardContext] is a `Map<String, Object>` that a [RouteNodeGuard] can read
/// from and write to in order to share state with guards that run later in the
/// same pipeline. A fresh context is created per mutation.
/// {@endtemplate}
abstract interface class GuardContext implements Map<String, Object> {
  /// Creates an empty [GuardContext].
  factory GuardContext() => GuardContextImpl();
}

@internal
class GuardContextImpl implements GuardContext {
  final _map = <String, Object>{};

  @override
  Object? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, Object value) => _map[key] = value;

  @override
  void addAll(Map<String, Object> other) => _map.addAll(other);

  @override
  void addEntries(
    Iterable<MapEntry<String, Object>> newEntries,
  ) =>
      _map.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _map.cast<RK, RV>();

  @override
  void clear() => _map.clear();

  @override
  bool containsKey(Object? key) => _map.containsKey(key);

  @override
  bool containsValue(Object? value) => _map.containsValue(value);

  @override
  Iterable<MapEntry<String, Object>> get entries => _map.entries;

  @override
  void forEach(void Function(String key, Object value) action) =>
      _map.forEach(action);

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<String> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(String key, Object value) convert,
  ) =>
      _map.map(convert);

  @override
  Object putIfAbsent(
    String key,
    Object Function() ifAbsent,
  ) =>
      _map.putIfAbsent(key, ifAbsent);

  @override
  Object? remove(Object? key) => _map.remove(key);

  @override
  void removeWhere(
    bool Function(String key, Object value) test,
  ) =>
      _map.removeWhere(test);

  @override
  Object update(
    String key,
    Object Function(Object value) update, {
    Object Function()? ifAbsent,
  }) =>
      _map.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(
    Object Function(String key, Object value) update,
  ) =>
      _map.updateAll(update);

  @override
  Iterable<Object> get values => _map.values;
}
