import 'dart:async';

import 'package:yx_scope/yx_scope.dart';

import '../../domain/order/models/order.dart';
import '../../domain/order/order_manager.dart';
import '../../domain/order/order_position_manager.dart';
import '../../domain/order/orders_state_holder.dart';
import '../utils/listeners.dart';

abstract class OrderScope implements Scope {
  OrderManager get orderManager;

  OrderPositionHolder get orderPositionHolder;
}

abstract class OrderScopeParent implements Scope {
  OrdersHandler get ordersHandler;

  void onStartOrderNavigation(Order order, int lastPosition);
}

class OrderScopeContainer
    extends ChildDataScopeContainer<OrderScopeParent, Order>
    implements OrderScope {
  OrderScopeContainer({
    required super.parent,
    required super.data,
  });

  late final _orderManagerDep = dep(
    () => OrderManager(
      data,
      parent.ordersHandler,
      _orderPositionHolderDep.get,
      parent.onStartOrderNavigation,
    ),
  );

  late final _orderPositionHolderDep = dep(() => OrderPositionHolder(data));

  @override
  OrderManager get orderManager => _orderManagerDep.get;

  @override
  OrderPositionHolder get orderPositionHolder => _orderPositionHolderDep.get;
}

class OrderScopesHolder implements OrdersStateHolder {
  final OrderScopeParent parent;

  final _controller =
      StreamController<Map<Order, OrderScopeHolder>>.broadcast();

  final orderScopes = <Order, OrderScopeHolder>{};

  Stream<Map<Order, OrderScopeHolder>> get orderScopesStream =>
      _controller.stream;

  OrderScopesHolder(this.parent);

  @override
  Future<void> addOrder(Order order) async {
    final holder = OrderScopeHolder(parent);
    orderScopes[order] = holder;
    await holder.create(order);
    _notifyListeners();
  }

  @override
  Future<void> removeOrder(Order order) async {
    await orderScopes.remove(order)?.drop();
    _notifyListeners();
  }

  @override
  List<OrderManager> get orders =>
      orderScopes.values.map((e) => e.scope).toList().fold(
        [],
        (previousValue, scope) {
          if (scope != null) {
            previousValue.add(scope.orderManager);
          }
          return previousValue;
        },
      );

  void _notifyListeners() {
    _controller.add(orderScopes);
  }

  @override
  Stream<List<OrderManager>> get ordersStream =>
      _controller.stream.map((scopes) => scopes.values
          .map((holder) => holder.scope)
          .whereType<OrderScopeContainer>()
          .map((scope) => scope._orderManagerDep.get)
          .toList(growable: false));
}

class OrderScopeHolder extends BaseChildDataScopeHolder<OrderScope,
    OrderScopeContainer, OrderScopeParent, Order> {
  OrderScopeHolder(super.parent)
      : super(
          scopeObservers: [diObserver],
          depObservers: [diObserver],
          asyncDepObservers: [diObserver],
        );

  @override
  OrderScopeContainer createContainer(OrderScopeParent parent, Order data) =>
      OrderScopeContainer(parent: parent, data: data);
}
