import 'package:yx_scope/yx_scope.dart';
import './main.dart';

class AppScopeHolderWithListener extends ScopeHolder<AppScopeContainer> {
  static const _listener = AppListener();

  AppScopeHolderWithListener()
      // ignore: deprecated_member_use
      : super(scopeListeners: [_listener], depListeners: [_listener]);

  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}

// ignore: deprecated_member_use
class AppListener implements ScopeListener, DepListener, AsyncDepListener {
  const AppListener();

  static void _log(
    String message, [
    Object? exception,
    StackTrace? stackTrace,
  ]) {
    print(message);
    if (exception != null) {
      print(exception);
      if (stackTrace != null) {
        print(stackTrace);
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
  void onDepDisposeFailed(
          ScopeId scope, DepId dep, Object exception, StackTrace stackTrace) =>
      _log('[$scope.$dep] -> onDepDisposeFailed', exception, stackTrace);

  @override
  void onDepDisposed(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onDepDisposed');

  @override
  void onDepInitializeFailed(
          ScopeId scope, DepId dep, Object exception, StackTrace stackTrace) =>
      _log('[$scope.$dep] -> onDepInitializeFailed', exception, stackTrace);

  @override
  void onDepInitialized(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onDepInitialized');

  @override
  void onDepStartDispose(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onDepStartDispose');

  @override
  void onDepStartInitialize(ScopeId scope, DepId dep) =>
      _log('[$scope.$dep] -> onDepStartInitialize');
}
