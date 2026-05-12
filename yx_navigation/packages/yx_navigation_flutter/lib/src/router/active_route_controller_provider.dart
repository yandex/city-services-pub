import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// {@template active_route_controller_provider}
/// Provides [ActiveRouteController] and/or indexed-stack branch top [YxRoute]
/// for descendant widgets.
/// {@endtemplate}
class ActiveRouteControllerProvider extends StatelessWidget {
  /// Creates a widget that provides [controller] to descendants.
  ///
  /// {@macro active_route_controller_provider}
  ActiveRouteControllerProvider({
    required ActiveRouteController controller,
    required Widget child,
    super.key,
  }) : child = _ActiveRouteControllerInherited(
          controller: controller,
          child: child,
        );

  /// Creates a widget that exposes the active branch's top [YxRoute] to
  /// descendants.
  ///
  /// Used inside an [IndexedStack] slot so descendants can identify which
  /// branch they belong to.
  ActiveRouteControllerProvider.branch({
    required YxRoute route,
    required Widget child,
    super.key,
  }) : child = _IndexedStackBranchRouteInherited(
          branchRoute: route,
          child: child,
        );

  /// The subtree wrapped by this provider.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;

  /// Returns the [ActiveRouteController] associated with the current [BuildContext].
  static ActiveRouteController controllerOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      ArgumentError.checkNotNull(
        controllerMaybeOf(context, listen: listen),
        'ActiveRouteControllerProvider.controllerOf',
      );

  /// Returns the [ActiveRouteController] associated with the current [BuildContext],
  /// or `null` if there is no controller scope in the tree.
  static ActiveRouteController? controllerMaybeOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _maybeOfActiveRouteController(context, listen: listen)?.controller;

  /// Returns the branch top [YxRoute] from the nearest
  /// [ActiveRouteControllerProvider.branch] ancestor, or `null` if none.
  static YxRoute? branchRouteMaybeOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _branchRouteMaybeOf(context, listen: listen)?.branchRoute;

  static _ActiveRouteControllerInherited? _maybeOfActiveRouteController(
    BuildContext context, {
    bool listen = true,
  }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<
          _ActiveRouteControllerInherited>();
    }

    return context
        .getInheritedWidgetOfExactType<_ActiveRouteControllerInherited>();
  }

  static _IndexedStackBranchRouteInherited? _branchRouteMaybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<
          _IndexedStackBranchRouteInherited>();
    }

    return context
        .getInheritedWidgetOfExactType<_IndexedStackBranchRouteInherited>();
  }
}

class _ActiveRouteControllerInherited extends InheritedWidget {
  const _ActiveRouteControllerInherited({
    required this.controller,
    required super.child,
  });

  final ActiveRouteController controller;

  @override
  bool updateShouldNotify(_ActiveRouteControllerInherited oldWidget) =>
      controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ActiveRouteController>(
        'controller',
        controller,
        showName: false,
      ),
    );
  }
}

class _IndexedStackBranchRouteInherited extends InheritedWidget {
  const _IndexedStackBranchRouteInherited({
    required this.branchRoute,
    required super.child,
  });

  final YxRoute branchRoute;

  @override
  bool updateShouldNotify(_IndexedStackBranchRouteInherited oldWidget) =>
      branchRoute != oldWidget.branchRoute;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<YxRoute>(
        'branchRoute',
        branchRoute,
        showName: false,
      ),
    );
  }
}
