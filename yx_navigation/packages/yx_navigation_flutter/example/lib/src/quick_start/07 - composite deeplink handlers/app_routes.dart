import 'package:yx_navigation/yx_navigation.dart';

abstract final class AppRoutes {
  static const home = YxRoute(id: 'home');
  static const orderDetails = YxRoute(id: 'order_details');
  static const orderDetailsV2 = YxRoute(id: 'order_details_v2');
  static const ordersList = YxRoute(id: 'orders_list');
  static const promo = YxRoute(id: 'promo');
  static const profile = YxRoute(id: 'profile');
}
