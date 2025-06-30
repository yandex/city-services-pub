import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/account/account_scope.dart';
import '../../di/order/order_scope.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScopeBuilder<AccountScope>.withPlaceholder(
        builder: (context, scope) {
          final onlineStateHolder = scope.onlineScopeHolder;
          return Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    StreamBuilder(
                      initialData: onlineStateHolder.isOnline,
                      stream: onlineStateHolder.isOnlineStream,
                      builder: (context, snap) {
                        final isOnline = snap.requireData;
                        return Column(
                          children: [
                            TextButton(
                              onPressed: () => onlineStateHolder.toggle(),
                              child: Text(
                                isOnline ? 'Go Offline' : 'Go Online',
                              ),
                            ),
                            Text(
                              isOnline ? 'Wait for orders' : 'You are offline',
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: StreamBuilder(
                  initialData: scope.orderScopesHolder.orderScopes,
                  stream: scope.orderScopesHolder.orderScopesStream,
                  builder: (context, snap) {
                    final data = snap.data;
                    if (data == null) {
                      return const SizedBox.shrink();
                    }

                    final orderList = data.values.toList(growable: false);

                    return ListView.builder(
                      itemCount: orderList.length,
                      itemBuilder: (context, index) {
                        final orderScopeHolder = orderList[index];
                        return ScopeBuilder<OrderScope>.withPlaceholder(
                            holder: orderScopeHolder,
                            builder: (context, orderScope) {
                              final manager = orderScope.orderManager;
                              final order = manager.order;
                              return ListTile(
                                title: Text(
                                  '${order.incomingOrder.fromAddress.name}'
                                  ' -> ${order.incomingOrder.toAddress.name}',
                                ),
                                subtitle: Text(
                                  'uid: ${order.uid}',
                                ),
                                trailing: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          manager.goToMapNavigation(),
                                      child: const Text('Navigate'),
                                    ),
                                    TextButton(
                                      onPressed: () => manager.cancelOrder(),
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
