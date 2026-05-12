import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../router/active_route_controller_provider.dart';

/// {@template back_button_handler}
/// Handles the system back button for a nested navigator.
///
/// Implementations decide whether a back press is consumed by the current
/// navigator (returning `true`) or should bubble up to the parent navigator
/// or platform (returning `false`).
/// {@endtemplate}
abstract interface class BackButtonHandler {
  /// Invoked when the user presses the back button.
  ///
  /// Returns `true` if the event was consumed, `false` to let the framework
  /// propagate it further.
  Future<bool> call(
    BuildContext context,
    RouteNode routeNode,
    NavigatorState navigator,
  );
}

/// Default [BackButtonHandler] implementation.
///
/// Pops the top route from [NavigatorState] when the current [ModalRoute] is
/// the topmost one and, if an [ActiveRouteControllerProvider] is present,
/// only when the current branch is active. Otherwise it defers to the parent
/// navigator by returning `false`.
@immutable
class DefaultBackButtonHandler implements BackButtonHandler {
  /// Creates a [DefaultBackButtonHandler].
  const DefaultBackButtonHandler();

  @override
  Future<bool> call(
    BuildContext context,
    RouteNode routeNode,
    NavigatorState navigator,
  ) {
    // Non-current route: e.g. dialog shown above this outlet — let the top route handle back.
    final currentRoute = ModalRoute.of(context);
    if (currentRoute != null && !currentRoute.isCurrent) {
      return SynchronousFuture<bool>(false);
    }

    final controller = ActiveRouteControllerProvider.controllerMaybeOf(
      context,
      listen: false,
    );

    if (controller != null) {
      final branchRoute = ActiveRouteControllerProvider.branchRouteMaybeOf(
        context,
        listen: false,
      );
      if (branchRoute != null && !controller.isRouteActive(branchRoute)) {
        return SynchronousFuture<bool>(false);
      }
    }

    return navigator.maybePop();
  }
}
