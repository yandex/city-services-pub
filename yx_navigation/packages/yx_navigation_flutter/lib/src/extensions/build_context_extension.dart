import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../base/route_node_builder.dart';
import '../router/yx_navigation.dart';

/// The extension methods are designed to provide convenient access
/// to these objects within the [BuildContext].
extension BuildContextExtension on BuildContext {
  /// Returns the [RouteNodeStateManager] associated with the [BuildContext].
  @internal
  RouteNodeStateManager get stateManager =>
      YxNavigation.stateManagerOf(this, listen: false);

  /// Returns the [NavigationController] associated with the [BuildContext].
  @internal
  NavigationController? get navigationController =>
      YxNavigation.navigationControllerOf(this, listen: false);

  /// Returns the [RouteNavigator] associated with the [BuildContext].
  RouteNavigator get routeNavigator =>
      YxNavigation.navigatorOf(this, listen: false);

  /// Returns the parent [RouteNavigator] associated with the [BuildContext].
  RouteNavigator? get parentRouteNavigator =>
      YxNavigation.parentNavigatorOf(this, listen: false);

  /// Returns the root [RouteNavigator] associated with the [BuildContext].
  RouteNavigator get rootRouteNavigator =>
      YxNavigation.navigatorOf(this, listen: false, isRoot: true);

  /// Returns the [RouteMutator] associated with the [BuildContext].
  RouteMutator get routeMutator => YxNavigation.mutatorOf(this, listen: false);

  /// Returns the [RouteNodeBuilder] associated with the [BuildContext].
  RouteNodeBuilder get routeNodeBuilder =>
      YxNavigation.routeNodeBuilderOf(this, listen: false);
}
