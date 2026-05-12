import 'package:yx_navigation/yx_navigation.dart';

/// Routes for the driver app.
abstract class DriverRoutes {
  /// Sign-in page.
  static const login = YxRoute(id: 'driver-login');

  /// Home dashboard.
  static const home = YxRoute(id: 'driver-home');

  /// Orders - active and available orders.
  static const orders = YxRoute(id: 'driver-orders');

  /// Messages - support chat and notifications.
  static const messages = YxRoute(id: 'driver-messages');

  /// Driver profile (nested schema).
  /// This route uses RouteDeclaration.scheme to mount the entire
  /// ProfileNavigationSchema.
  static const profile = YxRoute(id: 'driver-profile');
}
