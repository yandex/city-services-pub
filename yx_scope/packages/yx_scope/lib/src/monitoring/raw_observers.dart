import '../base_scope_container.dart';

part 'raw_listeners.dart';

/// Consider using [ScopeObserver], [DepObserver] and [AsyncDepObserver] instead — these are Observers with a safe read-only access.
/// [RawScopeObserver], [RawDepObserver] and [RawAsyncDepObserver] are an advanced direct access for rare cases.
/// So if you are not sure if this is the right choice for you then it's probably not.
///
/// [RawScopeObserver] is the Observer with a direct access to [BaseScopeContainer] and [Dep].
abstract class RawScopeObserver {
  static RawScopeObserver? override;

  RawScopeObserver._();

  void onScopeStartInitialize(BaseScopeContainer scope);

  void onScopeInitialized(BaseScopeContainer scope);

  void onScopeInitializeFailed(
    BaseScopeContainer scope,
    Object exception,
    StackTrace stackTrace,
  );

  void onScopeStartDispose(BaseScopeContainer scope);

  void onScopeDisposed(BaseScopeContainer scope);

  void onScopeDisposeDepFailed(
    BaseScopeContainer scope,
    Dep dep,
    Object exception,
    StackTrace stackTrace,
  );
}

/// [RawDepObserver] is the Observer with a direct access to [BaseScopeContainer], [Dep] and created instance.
/// More details in [RawScopeObserver]
abstract class RawDepObserver {
  static RawDepObserver? override;

  void onValueStartCreate(BaseScopeContainer scope, Dep dep);

  void onValueCreated(BaseScopeContainer scope, Dep dep, Object? value);

  void onValueCreateFailed(
    BaseScopeContainer scope,
    Dep dep,
    Object exception,
    StackTrace stackTrace,
  );

  void onValueCleared(BaseScopeContainer scope, Dep dep, Object? value);
}

/// [RawAsyncDepObserver] is the Observer with a direct access to [BaseScopeContainer] and [Dep].
/// More details in [RawScopeObserver]
abstract class RawAsyncDepObserver implements RawDepObserver {
  static RawAsyncDepObserver? override;

  void onDepStartInitialize(BaseScopeContainer scope, Dep dep);

  void onDepInitialized(BaseScopeContainer scope, Dep dep);

  void onDepStartDispose(BaseScopeContainer scope, Dep dep);

  void onDepDisposed(BaseScopeContainer scope, Dep dep);

  void onDepInitializeFailed(
    BaseScopeContainer scope,
    Dep dep,
    Object exception,
    StackTrace stackTrace,
  );

  void onDepDisposeFailed(
    BaseScopeContainer scope,
    Dep dep,
    Object exception,
    StackTrace stackTrace,
  );
}
