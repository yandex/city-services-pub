import 'package:flutter/foundation.dart';
import 'package:yx_scope/yx_scope.dart';

const diObserver = DIObserver();

class DIObserver implements ScopeObserver, DepObserver, AsyncDepObserver {
  const DIObserver();

  static void _log(
    String message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      print(message);
      if (exception != null) {
        print(exception);
        if (stackTrace != null) {
          print(stackTrace);
        }
      }
    }
  }

  @override
  void onScopeStartInitialize(ScopeId scope) =>
      _log('[$scope] -> onScopeStartInitialize');

  @override
  void onScopeInitialized(ScopeId scope) =>
      _log('[$scope] -> onScopeInitialized');

  @override
  void onScopeInitializeFailed(
    ScopeId scope,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log('[$scope] -> onScopeInitializeFailed', exception, stackTrace);

  @override
  void onScopeStartDispose(ScopeId scope) =>
      _log('[$scope] -> onScopeStartDispose');

  @override
  void onScopeDisposed(ScopeId scope) => _log('[$scope] -> onScopeDisposed');

  @override
  void onScopeDisposeDepFailed(
    ScopeId scope,
    DepId dep,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log('[$scope] -> onScopeDisposeDepFailed', exception, stackTrace);

  @override
  void onValueStartCreate(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onValueStartCreate');

  @override
  void onValueCreated(ScopeId scope, DepId dep, ValueMeta? valueMeta) =>
      _log('[$scope.$dep] -> onValueCreated');

  @override
  void onValueCreateFailed(
    ScopeId scope,
    DepId dep,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log('[$scope.$dep] -> onValueCreated', exception, stackTrace);

  @override
  void onValueCleared(ScopeId scope, DepId dep, ValueMeta? valueMeta) =>
      _log('[$scope.$dep]($valueMeta) -> onValueCleared');

  @override
  void onDepStartInitialize(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onDepStartInitialize');

  @override
  void onDepInitialized(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onDepInitialized');

  @override
  void onDepStartDispose(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onDepStartDispose');

  @override
  void onDepDisposed(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onDepDisposed');

  @override
  void onDepInitializeFailed(
    ScopeId scope,
    DepId dep,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log('[$scope.$dep] -> onDepInitializeFailed', exception, stackTrace);

  @override
  void onDepDisposeFailed(
    ScopeId scope,
    DepId dep,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log('[$scope.$dep] -> onDepDisposeFailed', exception, stackTrace);
}
