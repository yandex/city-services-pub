import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../di/map/map_scope.dart';
import '../../di/map_navigation/map_navigation_scope.dart';
import '../../di/order/order_scope.dart';
import '../../domain/map_navigation/map_navigation_manager.dart';
import '../../domain/order/models/order.dart';
import '../../router/models/app_state.dart';
import '../../router/router_delegate.dart';

class OrderNavigationDelegate {
  final AppRouterDelegate _appRouterDelegate;
  final MapScopeHolder _mapScopeHolder;
  final OrderScopesHolder _orderScopesHolder;

  StreamSubscription? _subscription;

  OrderNavigationDelegate(
    this._appRouterDelegate,
    this._mapScopeHolder,
    this._orderScopesHolder,
  );

  Future<void> onOrderNavigation(Order order, int lastPosition) async {
    if (_appRouterDelegate.state.tabbarPage != TabbarPageType.map) {
      _appRouterDelegate.setTabBarPage(TabbarPageType.map);
    }
    _subscription = _mapScopeHolder.stream
        .asyncExpand((scope) => scope == null
            ? Stream<MapNavigationScope?>.value(null)
            : scope.mapNavigationScopeHolder.stream)
        .asyncExpand((scope) => scope == null
            ? Stream<MapNavigationParams?>.value(null)
            : scope.mapNavigationManager.stream)
        .listen((params) {
      final position = params?.currentPosition;
      if (position != null) {
        _orderScopesHolder.orderScopes[order]?.scope?.orderPositionHolder
            .updatePosition(position);
        _log('Order position updated: $position');
      } else {
        _log('Order position update canceled');
        _subscription?.cancel();
      }
    });

    // wait for MapScope appears
    final mapScope = await _mapScopeHolder.stream
        .firstWhere((scope) => scope != null) as MapScope;

    await mapScope.mapNavigationHolder.startNavigation(
      MapNavigationParams(
        fromAddress: order.incomingOrder.fromAddress,
        toAddress: order.incomingOrder.toAddress,
        currentPosition: lastPosition,
      ),
    );
  }

  void _log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
