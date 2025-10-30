part of 'base_scope_container.dart';

/// A factory method that creates an entity in [Dep].
typedef DepBuilder<Value> = Value Function();

/// Callback creates an entity based on current [BaseScopeContainer]
/// and will be used as a primary factory for creating an entity.
typedef OverrideDepBuilder<Container extends BaseScopeContainer, Value> = Value
    Function(Container container);

/// Extract meta information about [Dep],
/// e.x. DepId.
/// This extra class helps to stay the interface of
/// the main [Dep] clean an contain only dep.get method.
///
/// This class must be used only locally and must not be
/// assigned to any field or global final or variable.
class DepMeta<T> {
  final Dep<T> _dep;

  DepMeta(Dep<T> dep) : _dep = dep;

  DepId get id => _dep._id;
}

/// A description for a dependency.
/// Basically this is a factory class for any custom entity.
class Dep<Value> {
  final DepBehavior<Value, Dep<Value>> _behavior;
  final String? _name;

  final BaseScopeContainer _scope;
  final DepBuilder<Value> _builder;
  final DepObserverInternal? _observer;

  late final DepId _id;
  DepAccess<Value, Dep<Value>> get _access => DepAccess(this);

  Dep._(
    this._scope,
    this._builder,
    this._behavior, {
    String? name,
    DepObserverInternal? observer,
  })  : _name = name,
        _observer = observer {
    _id = DepId(Value, hashCode, _name);
    _behavior.register(_access);
  }

  /// Returns an entity by request
  Value get get => _behavior.getValue(_access);
}

/// A description for a dependency that implements [AsyncLifecycle].
/// This dependency will be initialized and disposed along with [BaseScopeContainer].
class AsyncDep<Value> extends Dep<Value> {
  final AsyncDepCallback<Value> _initCallback;
  final AsyncDepCallback<Value> _disposeCallback;

  final AsyncDepObserverInternal? _asyncDepObserver;
  final AsyncDepBehavior<Value, AsyncDep<Value>> _asyncDepBehavior;

  @override
  AsyncDepAccess<Value, AsyncDep<Value>> get _access => AsyncDepAccess(this);

  AsyncDep._(
    BaseScopeContainer scope,
    DepBuilder<Value> builder,
    AsyncDepBehavior<Value, AsyncDep<Value>> behavior, {
    required AsyncDepCallback<Value> init,
    required AsyncDepCallback<Value> dispose,
    String? name,
    AsyncDepObserverInternal? observer,
  })  : _initCallback = init,
        _disposeCallback = dispose,
        _asyncDepObserver = observer,
        _asyncDepBehavior = behavior,
        super._(scope, builder, behavior, name: name, observer: observer);

  @override
  Value get get => _asyncDepBehavior.getValue(_access);
}

class _DepValue<T> {
  final T value;

  const _DepValue(this.value);
}

class CoreDepBehavior<V, D extends Dep<V>> extends DepBehavior<V, D> {
  _DepValue<V>? _value;

  var _registered = false;

  @override
  V getValue(DepAccess<V, D> access) {
    if (!_registered) {
      throw ScopeException(
        'You are trying to get an instance of $V '
        'from the Dep ${access.name ?? access.id.toString()}, '
        'but the Scope ${access.scope._name ?? access.scope.hashCode.toString()} has been disposed. '
        'Probably you stored an instance of the Dep '
        'somewhere away from the Scope. '
        'Do not keep a Dep instance separately from it\'s Scope, '
        'and access Dep instance only directly from the Scope.',
      );
    }

    final crtValue = _value;
    if (crtValue != null) {
      return crtValue.value;
    } else {
      try {
        access.observer?.onValueStartCreate(access.dep);
        final newValue = access.builder();

        _value = _DepValue(newValue);
        access.observer?.onValueCreated(access.dep, newValue);
        return newValue;
      } on Object catch (e, s) {
        access.observer?.onValueCreateFailed(access.dep, e, s);
        rethrow;
      }
    }
  }

  @override
  void register(DepAccess access) {
    access.scope._registerDep(access.dep);
    _registered = true;
  }

  @override
  void unregister(DepAccess access) {
    if (!_registered) {
      throw ScopeError(
        'Dep._unregister() is called when it\'s not really registered yet — '
        'this is definitely an error in the library, '
        'please contact an owner, if you see this message.',
      );
    }
    final value = _value?.value;
    _value = null;
    access.observer?.onValueCleared(access.dep, value);
    _registered = false;
  }
}

class CoreAsyncDepBehavior<V, D extends AsyncDep<V>>
    extends CoreDepBehavior<V, D> implements AsyncDepBehavior<V, D> {
  var _initialized = false;
  @override
  Future<void> init(AsyncDepAccess<V, D> access) async {
    final value = super.getValue(access);
    try {
      access.asyncDepObserver?.onDepStartInitialize(access.dep);
      await access.initCallback(value);
      _initialized = true;
      access.asyncDepObserver?.onDepInitialized(access.dep);
    } on Object catch (e, s) {
      access.asyncDepObserver?.onDepInitializeFailed(access.dep, e, s);
      rethrow;
    }
  }

  @override
  Future<void> dispose(AsyncDepAccess<V, D> access) async {
    assert(
      _initialized,
      'Dispose of ${access.dep.runtimeType} has been called without initialization',
    );
    final value = super.getValue(access);
    try {
      _initialized = false;
      access.asyncDepObserver?.onDepStartDispose(access.dep);
      await access.disposeCallback(value);
      access.asyncDepObserver?.onDepDisposed(access.dep);
    } on Object catch (e, s) {
      access.asyncDepObserver?.onDepDisposeFailed(access.dep, e, s);
      rethrow;
    }
  }

  @override
  V getValue(DepAccess<V, D> access) {
    assert(
      _initialized,
      'You have forgotten to add ${access.dep.runtimeType} to initializeQueue or it '
      'has been used before initialization by another dep. '
      'Try to reorder deps in initializeQueue.',
    );
    return super.getValue(access);
  }
}

/// A class that describes the behavior of a dependency.
/// It is helpful to create a custom behavior for a dependency.
abstract class DepBehavior<V, D extends Dep<V>> {
  void register(DepAccess access);

  void unregister(DepAccess access);

  V getValue(DepAccess<V, D> access);
}

abstract class AsyncDepBehavior<V, D extends AsyncDep<V>>
    extends DepBehavior<V, D> {
  Future<void> init(AsyncDepAccess<V, D> access);

  Future<void> dispose(AsyncDepAccess<V, D> access);
}

class DepAccess<V, D extends Dep<V>> {
  final D dep;

  String? get name => dep._name;

  BaseScopeContainer get scope => dep._scope;
  DepBuilder<V> get builder => dep._builder;
  DepObserverInternal? get observer => dep._observer;

  DepId get id => dep._id;

  DepAccess(this.dep);
}

class AsyncDepAccess<V, D extends AsyncDep<V>> extends DepAccess<V, D> {
  AsyncDepCallback<V> get initCallback => dep._initCallback;
  AsyncDepCallback<V> get disposeCallback => dep._disposeCallback;

  AsyncDepObserverInternal? get asyncDepObserver => dep._asyncDepObserver;

  AsyncDepAccess(super.dep);
}
