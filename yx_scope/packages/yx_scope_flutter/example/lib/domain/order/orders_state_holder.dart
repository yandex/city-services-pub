import 'models/order.dart';
import 'order_manager.dart';

abstract class OrdersStateHolder implements OrdersStates, OrdersHandler {}

abstract class OrdersStates {
  Stream<List<OrderManager>> get ordersStream;

  List<OrderManager> get orders;
}

abstract class OrdersHandler {
  Future<void> addOrder(Order order);

  Future<void> removeOrder(Order order);
}
