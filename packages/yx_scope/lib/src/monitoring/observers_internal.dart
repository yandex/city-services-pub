part of '../base_scope_container.dart';

/// DO NOT USE THIS CLASS MANUALLY
///
/// [RawScopeObserver] implementation for [CoreScopeHolder] that notifies
/// [ScopeObserver]s
class ScopeObserverInternal implements RawScopeObserver {
  final List<ScopeObserver>? _observers;

  const ScopeObserverInternal(this._observers);

  @override
  void onScopeStartInitialize(BaseScopeContainer scope) {
    RawScopeObserver.override?.safeNotify(
      (listener) => listener.onScopeStartInitialize(scope),
    );
    _safeNotifyAll<ScopeObserver>(
      _observers,
      (listener) => listener.onScopeStartInitialize(scope._id),
    );
  }

  @override
  void onScopeInitialized(BaseScopeContainer scope) {
    RawScopeObserver.override?.safeNotify(
      (listener) => listener.onScopeInitialized(scope),
    );
    _safeNotifyAll<ScopeObserver>(
      _observers,
      (listener) => listener.onScopeInitialized(scope._id),
    );
  }

  @override
  void onScopeInitializeFailed(
    BaseScopeContainer scope,
    Object exception,
    StackTrace stackTrace,
  ) {
    RawScopeObserver.override?.safeNotify(
      (listener) => listener.onScopeInitializeFailed(
        scope,
        exception,
        stackTrace,
      ),
    );
    _safeNotifyAll<ScopeObserver>(
      _observers,
      (listener) => listener.onScopeInitializeFailed(
        scope._id,
        exception,
        stackTrace,
      ),
    );
  }

  @override
  void onScopeStartDispose(BaseScopeContainer scope) {
    RawScopeObserver.override?.safeNotify(
      (listener) => listener.onScopeStartDispose(scope),
    );
    _safeNotifyAll<ScopeObserver>(
      _observers,
      (listener) => listener.onScopeStartDispose(scope._id),
    );
  }

  @override
  void onScopeDisposed(BaseScopeContainer scope) {
    RawScopeObserver.override?.safeNotify(
      (listener) => listener.onScopeDisposed(scope),
    );
    _safeNotifyAll<ScopeObserver>(
      _observers,
      (listener) => listener.onScopeDisposed(scope._id),
    );
  }

  @override
  void onScopeDisposeDepFailed(
    BaseScopeContainer scope,
    Dep dep,
    Object exception,
    StackTrace stackTrace,
  ) {
    RawScopeObserver.override?.safeNotify(
      (listener) => listener.onScopeDisposeDepFailed(
        scope,
        dep,
        exception,
        stackTrace,
      ),
    );
    _safeNotifyAll<ScopeObserver>(
      _observers,
      (listener) => listener.onScopeDisposeDepFailed(
        scope._id,
        dep._id,
        exception,
        stackTrace,
      ),
    );
  }
}

/// DO NOT USE THIS CLASS MANUALLY
///
/// [RawDepObserver] implementation for [Dep] that notifies
/// [DepObserver]s
class DepObserverInternal {
  final BaseScopeContainer _scope;
  List<DepObserver>? _observers;

  DepObserverInternal(this._scope);

  void onValueStartCreate(Dep dep) {
    RawDepObserver.override?.safeNotify(
      (listener) => listener.onValueStartCreate(_scope, dep),
    );
    _safeNotifyAll<DepObserver>(
      _observers,
      (listener) => listener.onValueStartCreate(_scope._id, dep._id),
    );
  }

  void onValueCreated(Dep dep, Object? value) {
    RawDepObserver.override?.safeNotify(
      (listener) => listener.onValueCreated(_scope, dep, value),
    );
    _safeNotifyAll<DepObserver>(
      _observers,
      (listener) => listener.onValueCreated(
        _scope._id,
        dep._id,
        ValueMeta.build(value),
      ),
    );
  }

  void onValueCreateFailed(
    Dep dep,
    Object exception,
    StackTrace stackTrace,
  ) {
    RawDepObserver.override?.safeNotify(
      (listener) => listener.onValueCreateFailed(
        _scope,
        dep,
        exception,
        stackTrace,
      ),
    );
    _safeNotifyAll<DepObserver>(
      _observers,
      (listener) => listener.onValueCreateFailed(
        _scope._id,
        dep._id,
        exception,
        stackTrace,
      ),
    );
  }

  void onValueCleared(Dep dep, Object? value) {
    RawDepObserver.override?.safeNotify(
      (listener) => listener.onValueCleared(_scope, dep, value),
    );
    _safeNotifyAll<DepObserver>(
      _observers,
      (listener) => listener.onValueCleared(
        _scope._id,
        dep._id,
        ValueMeta.build(value),
      ),
    );
  }
}

/// DO NOT USE THIS CLASS MANUALLY
///
/// [RawDepObserver] implementation for [AsyncDep] that notifies
/// [AsyncDepObserver]s
class AsyncDepObserverInternal extends DepObserverInternal {
  List<AsyncDepObserver>? _asyncDepObservers;

  AsyncDepObserverInternal(BaseScopeContainer scope) : super(scope);

  void onDepStartInitialize(Dep dep) {
    RawAsyncDepObserver.override?.safeNotify(
      (listener) => listener.onDepStartInitialize(_scope, dep),
    );
    _safeNotifyAll<AsyncDepObserver>(
      _asyncDepObservers,
      (listener) => listener.onDepStartInitialize(_scope._id, dep._id),
    );
  }

  void onDepInitialized(Dep dep) {
    RawAsyncDepObserver.override?.safeNotify(
      (listener) => listener.onDepInitialized(_scope, dep),
    );
    _safeNotifyAll<AsyncDepObserver>(
      _asyncDepObservers,
      (listener) => listener.onDepInitialized(_scope._id, dep._id),
    );
  }

  void onDepStartDispose(Dep dep) {
    RawAsyncDepObserver.override?.safeNotify(
      (listener) => listener.onDepStartDispose(_scope, dep),
    );
    _safeNotifyAll<AsyncDepObserver>(
      _asyncDepObservers,
      (listener) => listener.onDepStartDispose(_scope._id, dep._id),
    );
  }

  void onDepDisposed(Dep dep) {
    RawAsyncDepObserver.override?.safeNotify(
      (listener) => listener.onDepDisposed(_scope, dep),
    );
    _safeNotifyAll<AsyncDepObserver>(
      _asyncDepObservers,
      (listener) => listener.onDepDisposed(_scope._id, dep._id),
    );
  }

  void onDepInitializeFailed(
    Dep dep,
    Object exception,
    StackTrace stackTrace,
  ) {
    RawAsyncDepObserver.override?.safeNotify(
      (listener) => listener.onDepInitializeFailed(
        _scope,
        dep,
        exception,
        stackTrace,
      ),
    );
    _safeNotifyAll<AsyncDepObserver>(
      _asyncDepObservers,
      (listener) => listener.onDepInitializeFailed(
        _scope._id,
        dep._id,
        exception,
        stackTrace,
      ),
    );
  }

  void onDepDisposeFailed(
    Dep dep,
    Object exception,
    StackTrace stackTrace,
  ) {
    RawAsyncDepObserver.override?.safeNotify(
      (listener) => listener.onDepDisposeFailed(
        _scope,
        dep,
        exception,
        stackTrace,
      ),
    );
    _safeNotifyAll<AsyncDepObserver>(
      _asyncDepObservers,
      (listener) => listener.onDepDisposeFailed(
        _scope._id,
        dep._id,
        exception,
        stackTrace,
      ),
    );
  }
}

extension _SafeNotification<T> on T {
  void safeNotify(void Function(T it) callback) {
    try {
      callback(this);
    } on Object catch (e, s) {
      Logger.warning(
        'An error occurred in a listener $T#$hashCode: $e\n$s',
      );
    }
  }
}

void _safeNotifyAll<T>(
  List<T>? listeners,
  void Function(T listener) callback,
) {
  if (listeners == null) {
    return;
  }
  for (final listener in listeners) {
    listener.safeNotify(callback);
  }
}
