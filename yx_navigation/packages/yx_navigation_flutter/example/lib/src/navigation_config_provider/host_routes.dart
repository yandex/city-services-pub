import 'package:yx_navigation/yx_navigation.dart';

/// Routes for the host application.
abstract class HostRoutes {
  /// Home page of the host app.
  static const home = YxRoute(id: 'host-home');

  /// Settings page of the host app.
  static const settings = YxRoute(id: 'host-settings');

  /// "About" page.
  static const about = YxRoute(id: 'host-about');

  /// Driver profile (nested schema).
  static const profile = YxRoute(id: 'host-profile');

  /// Demo route for the empty state.
  static const demoEmpty = YxRoute(id: 'host-demo-empty');
}
