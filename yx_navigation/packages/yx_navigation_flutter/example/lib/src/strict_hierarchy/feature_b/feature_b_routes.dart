import 'package:yx_navigation/yx_navigation.dart';

/// Routes for Feature B (production-ready, strict hierarchy).
abstract class FeatureBRoutes {
  static const root = YxRoute(id: 'featureBRoot');
  static const home = YxRoute(id: 'featureBHome');
  static const dashboard = YxRoute(id: 'featureBDashboard');
  static const inNotAlloweInHome = YxRoute(id: 'inNotAlloweInHome');
}
