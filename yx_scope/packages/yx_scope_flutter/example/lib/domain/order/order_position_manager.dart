import 'models/order.dart';

class OrderPositionHolder {
  int position;

  OrderPositionHolder(Order order)
      : position = order.incomingOrder.fromAddress.position;

  void updatePosition(int position) => this.position = position;
}
