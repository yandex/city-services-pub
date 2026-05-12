import 'package:yx_navigation/yx_navigation.dart';

/// Routes for the driver-profile section.
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

  /// Demo route for the empty state.
  static const demoEmpty = YxRoute(id: 'profile-demo-empty');
}
