import '../../../data/orders/models/incoming_order_data.dart';

class Order {
  final IncomingOrder incomingOrder;

  Order(this.incomingOrder);

  String get uid => incomingOrder.uid;
}
