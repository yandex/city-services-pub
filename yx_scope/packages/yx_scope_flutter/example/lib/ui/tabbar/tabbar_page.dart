import 'package:flutter/material.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import '../../di/app/app_scope.dart';
import '../../router/models/app_state.dart';
import '../account/account_page.dart';
import '../map/map_page.dart';
import '../orders/accept_order_wrapper.dart';
import '../orders/orders_page.dart';

class TabbarPage extends StatefulWidget {
  final TabbarPageType page;

  const TabbarPage({super.key, required this.page});

  @override
  State<TabbarPage> createState() => _TabbarPageState();
}

class _TabbarPageState extends State<TabbarPage> {
  static const _orderOfPages = [
    TabbarPageType.map,
    TabbarPageType.orders,
    TabbarPageType.account,
  ];

  @override
  Widget build(BuildContext context) =>
      ScopeBuilder<AppScopeContainer>.withPlaceholder(
        builder: (context, appScope) {
          final routerDelegate = appScope.routerDelegateDep.get;
          late final Widget body;

          switch (widget.page) {
            case TabbarPageType.map:
              body = const MapPage();
              break;
            case TabbarPageType.orders:
              body = const OrdersPage();
              break;
            case TabbarPageType.account:
              body = const AccountPage();
              break;
          }
          return AcceptOrderWrapper(
            child: Scaffold(
              appBar: AppBar(title: Text(_labelFromType(widget.page))),
              body: body,
              bottomNavigationBar: NavigationBar(
                selectedIndex: widget.page.index,
                onDestinationSelected: (index) {
                  final type = _orderOfPages[index];
                  routerDelegate.setTabBarPage(type);
                },
                destinations: _destinations,
              ),
            ),
          );
        },
      );

  List<Widget> get _destinations => _orderOfPages
      .map(
        (type) => NavigationDestination(
          icon: _iconFromType(type),
          label: _labelFromType(type),
        ),
      )
      .toList();

  String _labelFromType(TabbarPageType type) {
    switch (type) {
      case TabbarPageType.map:
        return 'Map';
      case TabbarPageType.orders:
        return 'Orders';
      case TabbarPageType.account:
        return 'Account';
    }
  }

  Icon _iconFromType(TabbarPageType type) {
    switch (type) {
      case TabbarPageType.map:
        return const Icon(Icons.map);
      case TabbarPageType.orders:
        return const Icon(Icons.list);
      case TabbarPageType.account:
        return const Icon(Icons.account_box_outlined);
    }
  }
}
