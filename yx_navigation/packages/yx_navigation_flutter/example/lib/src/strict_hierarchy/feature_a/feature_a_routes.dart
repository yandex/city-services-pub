import 'package:yx_navigation/yx_navigation.dart';

/// Routes for Feature A (experimental, no strict hierarchy).
abstract class FeatureARoutes {
  static const home = YxRoute(id: 'featureAHome');
  static const details = YxRoute(id: 'featureADetails');
  static const settings = YxRoute(id: 'featureASettings');
}
