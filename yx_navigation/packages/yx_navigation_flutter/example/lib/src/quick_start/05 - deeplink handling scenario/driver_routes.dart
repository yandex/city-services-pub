import 'package:yx_navigation/yx_navigation.dart';

/// Routes for deeplink handling demonstration
abstract class DriverRoutes {
  /// Home page
  static const home = YxRoute(id: 'driver-home');

  /// Order details page
  static const orderDetails = YxRoute(id: 'driver-order-details');

  /// Driver profile
  static const profile = YxRoute(id: 'driver-profile');

  /// App settings
  static const settings = YxRoute(id: 'driver-settings');
}
