import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../di/app/app_scope.dart';
import '../ui/auth/auth_page.dart';
import '../ui/register/register_page.dart';
import '../ui/tabbar/tabbar_page.dart';
import 'models/app_state.dart';

class AppRouterDelegate extends RouterDelegate<AppState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppState> {
  var state = const AppState.init();
  @override
  late final navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final pages = <Page>[];
    if (!state.hasAccount) {
      pages.add(
        const MaterialPage(
          key: ValueKey('LoginPage'),
          child: AuthPage(),
        ),
      );
    } else {
      pages.add(
        MaterialPage(
          key: const ValueKey('TabBarPage'),
          child: ScopeBuilder<AppScopeContainer>.withPlaceholder(
            builder: (context, appScope) {
              return ScopeProvider(
                holder: appScope.accountScopeHolderDep.get,
                child: TabbarPage(page: state.tabbarPage),
              );
            },
          ),
        ),
      );
    }

    if (state.isOpenRegister) {
      pages.add(
        const MaterialPage(
          key: ValueKey('RegisterPage'),
          child: RegisterPage(),
        ),
      );
    }
    return Navigator(
      key: navigatorKey,
      pages: pages,
      // TODO: migrate to the new API
      // ignore: deprecated_member_use
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppState configuration) async {}

  void setHasAccount({required bool hasAccount}) {
    state = state.copyWith(hasAccount: hasAccount);
    notifyListeners();
  }

  void setOpenRegister({required bool isOpenRegister}) {
    state = state.copyWith(isOpenRegister: isOpenRegister);
    notifyListeners();
  }

  void setTabBarPage(TabbarPageType page) {
    state = state.copyWith(tabbarPage: page);
    notifyListeners();
  }
}
