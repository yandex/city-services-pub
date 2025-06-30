import 'dart:async';

import 'package:yx_scope/yx_scope.dart';

import '../../data/orders/incoming_orders_provider.dart';
import 'models/order.dart';
import 'orders_state_holder.dart';

/// This manager listens for incoming orders.
/// Has a [_maxCountOfOrders] limit.
class AcceptOrderManager implements AsyncLifecycle {
  static const _maxCountOfOrders = 3;

  final OrdersStateHolder _ordersStateHolder;
  final IncomingOrdersProvider _incomingOrdersProvider;

  final _controller = StreamController<Order>.broadcast();
  late IncomingOrderSession _session;
  StreamSubscription? _maxCountOfOrdersSub;

  AcceptOrderManager(
    this._ordersStateHolder,
    this._incomingOrdersProvider,
  );

  Stream<Order> get toAcceptOrdersStream => _controller.stream;

  Future<void> acceptOrder(Order order) async {
    await _ordersStateHolder.addOrder(order);
    _resumeIfNeeded();
  }

  Future<void> cancelOrder() async {
    _resumeIfNeeded();
  }

  @override
  Future<void> init() async {
    _session = _incomingOrdersProvider.incomingOrderSession;
    _session.incomingOrdersStream.listen((incomingOrder) {
      _controller.add(Order(incomingOrder));
      _session.pause();
    });
    _maxCountOfOrdersSub = _ordersStateHolder.ordersStream
        .map((orders) => orders.length)
        .listen((countOfOrders) {
      if (countOfOrders >= _maxCountOfOrders) {
        _session.pause();
      } else {
        _resumeIfNeeded();
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
    await _maxCountOfOrdersSub?.cancel();
    await _session.dispose();
  }

  void _resumeIfNeeded() {
    final session = _session;
    if (session.isPaused &&
        _ordersStateHolder.orders.length < _maxCountOfOrders) {
      session.resume();
    }
  }
}
