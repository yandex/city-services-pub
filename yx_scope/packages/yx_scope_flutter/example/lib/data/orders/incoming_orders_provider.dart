import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'models/incoming_order_data.dart';

class IncomingOrdersProvider {
  IncomingOrderSession get incomingOrderSession =>
      IncomingOrderSession().._init();
}

class IncomingOrderSession {
  final _controller = StreamController<IncomingOrder>.broadcast();
  late final StreamSubscription _subscription;

  Stream<IncomingOrder> get incomingOrdersStream => _controller.stream;

  bool get isPaused => _subscription.isPaused;

  void _init() {
    _subscription = Stream<IncomingOrder>.periodic(
      const Duration(seconds: 5),
      (_) => IncomingOrder(
        fromAddress: _getRandomAddress(),
        toAddress: _getRandomAddress(),
      ),
    ).listen((order) {
      _log('income order ${order.uid}');
      _controller.add(order);
    });
  }

  Future<void> dispose() async => await _subscription.cancel();

  void pause() {
    _log('pause to receive orders');
    _subscription.pause();
  }

  void resume() {
    _log('resume to receive orders');
    _subscription.resume();
  }

  void _log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}

Address _getRandomAddress() {
  final position = Random().nextInt(100);
  final street = 'Street $position';
  return Address(name: street, position: position);
}
