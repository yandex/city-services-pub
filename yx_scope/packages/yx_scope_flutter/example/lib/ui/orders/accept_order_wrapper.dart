import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/account/account_scope.dart';
import '../../di/online_order/online_scope.dart';
import '../../domain/order/models/order.dart';

class AcceptOrderWrapper extends StatefulWidget {
  final Widget child;

  const AcceptOrderWrapper({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<AcceptOrderWrapper> createState() => _AcceptOrderWrapperState();
}

class _AcceptOrderWrapperState extends State<AcceptOrderWrapper> {
  StreamSubscription? _acceptOrdersSub;

  @override
  void dispose() {
    super.dispose();
    _acceptOrdersSub?.cancel();
    _acceptOrdersSub = null;
  }

  void _listener(
    BuildContext _,
    OnlineScope? onlineScope,
  ) {
    if (onlineScope != null) {
      final acceptOrderManger = onlineScope.acceptOrderManager;

      _acceptOrdersSub?.cancel();
      _acceptOrdersSub = acceptOrderManger.toAcceptOrdersStream.listen((order) {
        if (!mounted) {
          return;
        }
        _handleIncomingOrder(onlineScope, order);
      });
      return;
    }

    _acceptOrdersSub?.cancel();
    _acceptOrdersSub = null;
  }

  Future<void> _handleIncomingOrder(
    OnlineScope onlineScope,
    Order order,
  ) async {
    final acceptOrderManager = onlineScope.acceptOrderManager;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Accept oder ${order.incomingOrder.fromAddress.name} -> ${order.incomingOrder.toAddress.name}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              acceptOrderManager.cancelOrder();
              Navigator.of(context).pop(false);
            },
            child: const Text('no'),
          ),
          TextButton(
            onPressed: () {
              acceptOrderManager.acceptOrder(order);
              Navigator.of(context).pop(true);
            },
            child: const Text('ok'),
          ),
        ],
      ),
    );
    if (result == null) {
      await acceptOrderManager.cancelOrder();
    }
  }

  @override
  Widget build(BuildContext context) =>
      ScopeBuilder<AccountScope>.withPlaceholder(
        builder: (context, accountScope) => ScopeListener<OnlineScope>(
          holder: accountScope.onlineScopeHolder,
          listener: _listener,
          child: widget.child,
        ),
      );
}
