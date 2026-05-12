import 'package:yx_navigation/yx_navigation.dart';

/// Routes for the Compatibility Mode demo.
///
/// Used to show the Navigator 1.0 API (push, pop, showDialog, etc.)
/// running inside an app that uses declarative YxNavigation.
abstract class CompatibilityRoutes {
  /// Demo home page.
  static const home = YxRoute(id: 'compatibility-home');

  /// Driver profile - demonstrates a Navigator 1.0 push.
  static const profile = YxRoute(id: 'compatibility-profile');
}
