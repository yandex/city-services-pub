import 'package:yx_navigation/yx_navigation.dart';

/// Routes for the driver application (scenario 04).
///
/// This example demonstrates a combined approach:
/// - Schema Declaration - for mounting nested features
/// - Business Logic First - for driving navigation from business logic
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
  ///
  /// Unlike scenario 03, the profile is driven through
  /// ProfileFeatureNavigationController.
  static const profile = YxRoute(id: 'driver-profile');
}
