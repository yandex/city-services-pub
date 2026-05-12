import 'package:yx_navigation/yx_navigation.dart';

/// Routes for the driver-profile feature.
///
/// These routes are internal to the feature and should not be visible to the
/// host application. The host app interacts only with the feature's root
/// route through RouteDeclaration.scheme.
abstract class ProfileRoutes {
  /// Profile home page - driver overview.
  static const home = YxRoute(id: 'profile-home');

  /// Driver profile - view and edit driver details.
  static const driverProfile = YxRoute(id: 'profile-driver');

  /// Trips history - list of completed orders.
  static const tripsHistory = YxRoute(id: 'profile-trips-history');

  /// Statistics - earnings and ratings analytics.
  static const statistics = YxRoute(id: 'profile-statistics');

  /// Settings - app configuration.
  static const settings = YxRoute(id: 'profile-settings');

  /// Documents - upload and manage documents.
  static const documents = YxRoute(id: 'profile-documents');
}
