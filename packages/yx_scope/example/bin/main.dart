import 'package:yx_scope/yx_scope.dart';

void main() async {
  final appScopeHolder = AppScopeHolder();

  await appScopeHolder.create();

  print(appScopeHolder.scope?.routerDelegateDep.get);

  await appScopeHolder.drop();

  print(appScopeHolder.scope?.routerDelegateDep.get);
}

class AppRouterDelegate {}

class AppStateObserver {
  final AppRouterDelegate appRouteDelegate;

  AppStateObserver(this.appRouteDelegate);
}

class AppScopeContainer extends ScopeContainer {
  late final routerDelegateDep = dep(() => AppRouterDelegate());

  late final appStateObserverDep = dep(
    () => AppStateObserver(
      routerDelegateDep.get,
    ),
  );
}

class AppScopeHolder extends ScopeHolder<AppScopeContainer> {
  static const _observer = AppObserver();

  AppScopeHolder()
      : super(scopeObservers: [_observer], depObservers: [_observer]);

  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}

class AppObserver implements ScopeObserver, DepObserver {
  const AppObserver();

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
}
