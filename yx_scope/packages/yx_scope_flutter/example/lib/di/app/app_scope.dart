import 'package:yx_scope/yx_scope.dart';

import '../../domain/auth/auth_manager.dart';
import '../../router/app_state_observer.dart';
import '../../router/router_delegate.dart';
import '../account/account_scope.dart';
import '../register/register_scope.dart';
import '../utils/listeners.dart';

class AppScopeContainer extends ScopeContainer {
  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {
          appStateObserverDep,
        }
      ];

  late final accountScopeHolderDep = dep(() => AccountScopeHolder(this));

  late final registerScopeHolderDep = dep(() => RegisterScopeHolder(this));

  late final authManagerDep = dep(
    () => AuthManager(
      accountScopeHolderDep.get,
      registerScopeHolderDep.get,
    ),
  );

  late final routerDelegateDep = dep(() => AppRouterDelegate());

  late final appStateObserverDep = asyncDep(
    () => AppStateObserver(
      routerDelegateDep.get,
      accountScopeHolderDep.get,
      registerScopeHolderDep.get,
    ),
  );
}

class AppScopeHolder extends ScopeHolder<AppScopeContainer> {
  AppScopeHolder()
      : super(
          scopeObservers: [diObserver],
          depObservers: [diObserver],
          asyncDepObservers: [diObserver],
        );

  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
