import 'dart:async';

import 'package:yx_scope/yx_scope.dart';

import '../../data/orders/incoming_orders_provider.dart';
import '../../domain/order/accept_order_manager.dart';
import '../../domain/order/online_order_state_holder.dart';
import '../../domain/order/orders_state_holder.dart';
import '../utils/listeners.dart';

abstract class OnlineScope implements Scope {
  AcceptOrderManager get acceptOrderManager;
}

abstract class OnlineScopeParent implements Scope {
  OrdersStateHolder get ordersStateHolder;
}

class OnlineScopeContainer extends ChildScopeContainer<OnlineScopeParent>
    implements OnlineScope {
  OnlineScopeContainer({required super.parent});

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_acceptOrderManagerDep}
      ];

  late final _incomingOrdersProviderDep = dep(() => IncomingOrdersProvider());

  late final _acceptOrderManagerDep = asyncDep(() => AcceptOrderManager(
        parent.ordersStateHolder,
        _incomingOrdersProviderDep.get,
      ));

  @override
  AcceptOrderManager get acceptOrderManager => _acceptOrderManagerDep.get;
}

class OnlineScopeHolder extends BaseChildScopeHolder<OnlineScope,
    OnlineScopeContainer, OnlineScopeParent> implements OnlineOrderStateHolder {
  OnlineScopeHolder(super.parent)
      : super(
          scopeObservers: [diObserver],
          depObservers: [diObserver],
          asyncDepObservers: [diObserver],
        );

  @override
  OnlineScopeContainer createContainer(OnlineScopeParent parent) =>
      OnlineScopeContainer(parent: parent);

  @override
  Stream<bool> get isOnlineStream => stream.map((scope) => scope != null);

  @override
  bool get isOnline => scope != null;

  @override
  Future<void> toggle() async {
    if (scope == null) {
      await create();
      return;
    }
    await drop();
  }
}
