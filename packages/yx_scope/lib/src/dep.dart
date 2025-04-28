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
  final String? _name;

  final BaseScopeContainer _scope;
  final DepBuilder<Value> _builder;
  final DepObserverInternal? _observer;

  late final DepId _id;

  _DepValue<Value>? _value;

  var _registered = false;

  Dep._(
    this._scope,
    this._builder, {
    String? name,
    DepObserverInternal? observer,
  })  : _name = name,
        _observer = observer {
    _id = DepId(Value, hashCode, _name);
    _scope._registerDep(this);
    _registered = true;
  }

  /// Returns an entity by request
  Value get get {
    if (!_registered) {
      throw ScopeException(
        'You are trying to get an instance of $Value '
        'from the Dep ${_name ?? hashCode.toString()}, '
        'but the Scope ${_scope._name ?? _scope.hashCode.toString()} has been disposed. '
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
        _observer?.onValueStartCreate(this);
        final newValue = _builder();

        _value = _DepValue(newValue);
        _observer?.onValueCreated(this, newValue);
        return newValue;
      } on Object catch (e, s) {
        _observer?.onValueCreateFailed(this, e, s);
        rethrow;
      }
    }
  }

  void _unregister() {
    if (!_registered) {
      throw ScopeError(
        'Dep._unregister() is called when it\'s not really registered yet — '
        'this is definitely an error in the library, '
        'please contact an owner, if you see this message.',
      );
    }
    final value = _value?.value;
    _value = null;
    _observer?.onValueCleared(this, value);
    _registered = false;
  }
}

/// A description for a dependency that implements [AsyncLifecycle].
/// This dependency will be initialized and disposed along with [BaseScopeContainer].
class AsyncDep<Value> extends Dep<Value> {
  final AsyncDepCallback<Value> _initCallback;
  final AsyncDepCallback<Value> _disposeCallback;

  final AsyncDepObserverInternal? _asyncDepObserver;

  var _initialized = false;

  AsyncDep._(
    BaseScopeContainer scope,
    DepBuilder<Value> builder, {
    required AsyncDepCallback<Value> init,
    required AsyncDepCallback<Value> dispose,
    String? name,
    AsyncDepObserverInternal? observer,
  })  : _initCallback = init,
        _disposeCallback = dispose,
        _asyncDepObserver = observer,
        super._(scope, builder, name: name, observer: observer);

  Future<void> _init() async {
    final value = super.get;
    try {
      _asyncDepObserver?.onDepStartInitialize(this);
      await _initCallback(value);
      _initialized = true;
      _asyncDepObserver?.onDepInitialized(this);
    } on Object catch (e, s) {
      _asyncDepObserver?.onDepInitializeFailed(this, e, s);
      rethrow;
    }
  }

  Future<void> _dispose() async {
    assert(
      _initialized,
      'Dispose of $runtimeType has been called without initialization',
    );
    final value = get;
    try {
      _initialized = false;
      _asyncDepObserver?.onDepStartDispose(this);
      await _disposeCallback(value);
      _asyncDepObserver?.onDepDisposed(this);
    } on Object catch (e, s) {
      _asyncDepObserver?.onDepDisposeFailed(this, e, s);
      rethrow;
    }
  }

  @override
  Value get get {
    assert(
      _initialized,
      'You have forgotten to add $runtimeType to initializeQueue or it '
      'has been used before initialization by another dep. '
      'Try to reorder deps in initializeQueue.',
    );
    return super.get;
  }
}

class _DepValue<T> {
  final T value;

  const _DepValue(this.value);
}
