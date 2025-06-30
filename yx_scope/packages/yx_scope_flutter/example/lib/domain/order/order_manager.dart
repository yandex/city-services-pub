import 'models/order.dart';
import 'order_position_manager.dart';
import 'orders_state_holder.dart';

typedef CancelOrderListener = void Function();

class OrderManager {
  final Order order;
  final OrdersHandler _ordersHandler;
  final OrderPositionHolder _orderPositionHolder;
  final void Function(Order order, int lastPosition) _onOrderNavigation;

  OrderManager(
    this.order,
    this._ordersHandler,
    this._orderPositionHolder,
    this._onOrderNavigation,
  );

  void goToMapNavigation() {
    _onOrderNavigation(order, _orderPositionHolder.position);
  }

  void cancelOrder() => _ordersHandler.removeOrder(order);
}
