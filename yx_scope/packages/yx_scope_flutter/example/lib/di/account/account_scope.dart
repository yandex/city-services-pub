import 'package:yx_scope/yx_scope.dart';

import '../../domain/auth/account_holder.dart';
import '../../domain/auth/models/account.dart';
import '../../domain/map/map_factory.dart';
import '../../domain/order/models/order.dart';
import '../../domain/order/orders_state_holder.dart';
import '../../domain/order_navigation/order_navigation_delegate.dart';
import '../app/app_scope.dart';
import '../map/map_scope.dart';
import '../online_order/online_scope.dart';
import '../order/order_scope.dart';
import '../utils/listeners.dart';

abstract class AccountScope implements Scope {
  Account get account;

  OnlineScopeHolder get onlineScopeHolder;

  OrderScopesHolder get orderScopesHolder;

  MapScopeHolder get mapScopeHolder;

  MapInitializer get mapInitializer;
}

class AccountScopeContainer
    extends ChildDataScopeContainer<AppScopeContainer, Account>
    implements AccountScope, OnlineScopeParent, OrderScopeParent {
  AccountScopeContainer({
    required super.parent,
    required super.data,
  });

  late final _onlineScopeHolderDep = dep(() => OnlineScopeHolder(this));

  late final _orderScopesHolderDep = dep(() => OrderScopesHolder(this));

  late final _mapScopeHolderDep = dep(() => MapScopeHolder());

  late final _orderNavigationDelegateDep = dep(
    () => OrderNavigationDelegate(
      parent.routerDelegateDep.get,
      _mapScopeHolderDep.get,
      _orderScopesHolderDep.get,
    ),
  );

  @override
  Account get account => data;

  @override
  OnlineScopeHolder get onlineScopeHolder => _onlineScopeHolderDep.get;

  @override
  OrderScopesHolder get orderScopesHolder => _orderScopesHolderDep.get;

  @override
  MapScopeHolder get mapScopeHolder => _mapScopeHolderDep.get;

  @override
  OrdersHandler get ordersHandler => ordersStateHolder;

  @override
  MapInitializer get mapInitializer => mapScopeHolder;

  @override
  OrdersStateHolder get ordersStateHolder => orderScopesHolder;

  @override
  void onStartOrderNavigation(Order order, int lastPosition) {
    _orderNavigationDelegateDep.get.onOrderNavigation(order, lastPosition);
  }
}

class AccountScopeHolder extends BaseChildDataScopeHolder<
    AccountScope,
    AccountScopeContainer,
    AppScopeContainer,
    Account> implements AccountHolder {
  AccountScopeHolder(super.parent)
      : super(
          scopeObservers: [diObserver],
          depObservers: [diObserver],
          asyncDepObservers: [diObserver],
        );

  @override
  AccountScopeContainer createContainer(
          AppScopeContainer parent, Account data) =>
      AccountScopeContainer(parent: parent, data: data);

  @override
  Account? get account => scope?.account;

  @override
  Stream<Account?> get accountStream => stream.map((scope) => scope?.account);

  @override
  Future<void> setAccount(Account account) async {
    await _dropIfNeeded();
    await create(account);
  }

  @override
  Future<void> dropAccount() async => _dropIfNeeded();

  Future<void> _dropIfNeeded() async {
    if (account != null) {
      await drop();
    }
  }
}
