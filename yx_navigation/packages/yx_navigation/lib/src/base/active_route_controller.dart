import 'package:meta/meta.dart';

import 'route.dart';

/// {@template active_route_controller}
/// Read and control the currently active route at the current level.
///
/// "Active" is the route that the user is interacting with right now, usually
/// the last entry in the children stack of the current node.
/// {@endtemplate}
@experimental
abstract interface class ActiveRouteController {
  /// The currently active [YxRoute], or `null` if no route is active.
  YxRoute? get activeRoute;

  /// A stream that emits whenever the active route changes.
  ///
  /// Emits distinct values only, so consecutive identical routes are
  /// collapsed into a single event.
  Stream<YxRoute?> get activeRouteStream;

  /// Returns `true` if [route] matches the currently active route.
  bool isRouteActive(YxRoute route);

  /// Marks [route] as active at the current level.
  ///
  /// Throws a [StateError] if [route] is not present in the current
  /// children list.
  void setActiveRoute(YxRoute route);
}
