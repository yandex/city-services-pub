import 'dart:async';

import 'package:yx_scope/yx_scope.dart';

import '../domain/auth/account_holder.dart';
import '../domain/auth/register_state_holder.dart';
import 'router_delegate.dart';

class AppStateObserver implements AsyncLifecycle {
  final AppRouterDelegate _routerDelegate;
  final AccountHolder _accountHolder;
  final RegisterHolder _registerHolder;

  late StreamSubscription _accountSubscription;
  late StreamSubscription _registerSubscription;

  AppStateObserver(
    this._routerDelegate,
    this._accountHolder,
    this._registerHolder,
  );

  @override
  Future<void> init() async {
    _accountSubscription = _accountHolder.accountStream.listen((account) {
      _routerDelegate.setHasAccount(hasAccount: account != null);
    });
    _registerSubscription =
        _registerHolder.inProgressStream.listen((inProgress) {
      _routerDelegate.setOpenRegister(isOpenRegister: inProgress);
    });
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      _accountSubscription.cancel(),
      _registerSubscription.cancel(),
    ]);
  }
}
