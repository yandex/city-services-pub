import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../base/route_node_builder.dart';

class _YxNavigationProvider extends StatefulWidget {
  /// {@macro route_node}
  final RouteNode routeNode;

  /// {@macro state_manager}
  final RouteNodeStateManager stateManager;

  /// {@macro navigation_controller}
  final NavigationController navigationController;

  /// {@macro parent_navigation_controller}
  final NavigationController parentNavigationController;

  /// {@macro route_node_builder}
  final RouteNodeBuilder routeNodeBuilder;

  final Widget child;

  const _YxNavigationProvider({
    required this.routeNode,
    required this.stateManager,
    required this.navigationController,
    required this.parentNavigationController,
    required this.routeNodeBuilder,
    required this.child,
    super.key,
  });

  @override
  State<_YxNavigationProvider> createState() => _YxNavigationProviderState();
}

class _YxNavigationProviderState extends State<_YxNavigationProvider> {
  StreamSubscription<RouteNode>? _rootRouteNodeReadableSubscription;
  late RouteNode _rootRouteNode;

  StreamSubscription<RouteNode?>? _parentRouteNodeReadableSubscription;
  RouteNode? _parentRouteNode;

  StreamSubscription<RouteNode?>? _currentRouteNodeReadableSubscription;
  RouteNode? _currentRouteNode;

  @override
  void initState() {
    super.initState();
    _initSubscriptions();
  }

  @override
  Widget build(BuildContext context) => YxNavigation._(
        routeNode: widget.routeNode,
        stateManager: widget.stateManager,
        rootRouteNode: _rootRouteNode,
        navigationController: widget.navigationController,
        currentRouteNode: _currentRouteNode,
        parentNavigationController: widget.parentNavigationController,
        parentRouteNode: _parentRouteNode,
        routeNodeBuilder: widget.routeNodeBuilder,
        key: widget.key,
        child: widget.child,
      );

  @override
  void didUpdateWidget(_YxNavigationProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.routeNode.equalsBy(oldWidget.routeNode) ||
        widget.stateManager != oldWidget.stateManager ||
        widget.navigationController != oldWidget.navigationController ||
        widget.parentNavigationController !=
            oldWidget.parentNavigationController ||
        widget.routeNodeBuilder != oldWidget.routeNodeBuilder ||
        widget.child != oldWidget.child) {
      _clearSubscriptions();
      _initSubscriptions();
    }
  }

  @override
  void dispose() {
    _clearSubscriptions();
    super.dispose();
  }

  void _initSubscriptions() {
    _rootRouteNode = widget.stateManager.state;
    _parentRouteNode = widget.parentNavigationController.state;
    _currentRouteNode = widget.navigationController.state;

    _rootRouteNodeReadableSubscription = widget.stateManager.stream.listen(
      (node) {
        if (mounted) {
          setState(() => _rootRouteNode = node);
        }
      },
    );

    _parentRouteNodeReadableSubscription =
        widget.parentNavigationController.stream.listen(
      (node) {
        if (mounted) {
          setState(() => _parentRouteNode = node);
        }
      },
    );

    _currentRouteNodeReadableSubscription =
        widget.navigationController.stream.listen(
      (node) {
        if (mounted) {
          setState(() => _currentRouteNode = node);
        }
      },
    );
  }

  void _clearSubscriptions() {
    _rootRouteNodeReadableSubscription?.cancel();
    _parentRouteNodeReadableSubscription?.cancel();
    _currentRouteNodeReadableSubscription?.cancel();

    _rootRouteNodeReadableSubscription = null;
    _parentRouteNodeReadableSubscription = null;
    _currentRouteNodeReadableSubscription = null;
  }
}

enum NavigationUpdateAspect { currentNode, parentNode, rootNode }

/// {@template yx_navigation}
/// Inherited entry point that exposes navigation APIs to descendant widgets.
///
/// Resolves the closest [RouteNavigator], [RouteMutator],
/// [NavigationController], and [RouteNodeStateManager] for the surrounding
/// [BuildContext]. Use the static lookup methods such as
/// [YxNavigation.navigatorOf] and [YxNavigation.mutatorOf] to read these
/// from widgets.
///
/// [YxNavigation] is an [InheritedModel]: it only notifies dependents when
/// the specific aspect they care about (current, parent, or root node) has
/// changed.
/// {@endtemplate}
@immutable
class YxNavigation extends InheritedModel<NavigationUpdateAspect> {
  /// {@macro route_node}
  final RouteNode routeNode;

  /// {@macro state_manager}
  final RouteNodeStateManager stateManager;

  /// {@macro navigation_controller}
  final NavigationController navigationController;

  /// {@macro parent_navigation_controller}
  final NavigationController parentNavigationController;

  /// {@macro route_node_builder}
  final RouteNodeBuilder routeNodeBuilder;

  final RouteNode _rootRouteNode;
  final RouteNode? _parentRouteNode;
  final RouteNode? _currentRouteNode;

  /// Creates an [YxNavigation] widget.
  ///
  /// {@macro yx_navigation}
  @internal
  static Widget provider({
    required RouteNode routeNode,
    required RouteNodeStateManager stateManager,
    required NavigationController navigationController,
    required NavigationController parentNavigationController,
    required RouteNodeBuilder routeNodeBuilder,
    required Widget child,
    Key? key,
  }) =>
      _YxNavigationProvider(
        routeNode: routeNode,
        stateManager: stateManager,
        navigationController: navigationController,
        parentNavigationController: parentNavigationController,
        routeNodeBuilder: routeNodeBuilder,
        key: key,
        child: child,
      );

  /// Creates an [YxNavigation] widget.
  ///
  /// {@macro yx_navigation}
  const YxNavigation._({
    required this.routeNode,
    required RouteNode rootRouteNode,
    required this.stateManager,
    required RouteNode? currentRouteNode,
    required this.navigationController,
    required RouteNode? parentRouteNode,
    required this.parentNavigationController,
    required this.routeNodeBuilder,
    required super.child,
    super.key,
  })  : _rootRouteNode = rootRouteNode,
        _parentRouteNode = parentRouteNode,
        _currentRouteNode = currentRouteNode;

  /// Returns the [RouteNodeStateManager] associated with the current [BuildContext].
  @internal
  static RouteNodeStateManager stateManagerOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _of(
        context,
        listen: listen,
        aspect: NavigationUpdateAspect.rootNode,
      ).stateManager;

  /// Returns the [NavigationController] associated with the
  /// current [BuildContext].
  @internal
  static NavigationController? navigationControllerOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _maybeOf(
        context,
        listen: listen,
        aspect: NavigationUpdateAspect.currentNode,
      )?.navigationController;

  /// Returns the [RouteNavigator] for the current subtree.
  ///
  /// When [isRoot] is `true`, returns the root navigator (the [RouteNodeStateManager])
  /// instead of the navigator bound to the enclosing route.
  static RouteNavigator navigatorOf(
    BuildContext context, {
    bool listen = true,
    bool isRoot = false,
  }) =>
      isRoot
          ? _of(
              context,
              listen: listen,
              aspect: NavigationUpdateAspect.rootNode,
            ).stateManager
          : _of(
              context,
              listen: listen,
              aspect: NavigationUpdateAspect.currentNode,
            ).navigationController;

  /// Returns the parent [NavigationController] for the current subtree.
  ///
  /// Throws if no parent controller is available in the tree.
  static NavigationController parentNavigatorOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _of(
        context,
        listen: listen,
        aspect: NavigationUpdateAspect.parentNode,
      ).parentNavigationController;

  /// Returns the parent [NavigationController] for the current subtree,
  /// or `null` when none is available.
  static NavigationController? mayBeParentNavigatorOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _maybeOf(
        context,
        listen: listen,
        aspect: NavigationUpdateAspect.parentNode,
      )?.parentNavigationController;

  /// Returns the [RouteMutator] that mutates the current subtree's state.
  static RouteMutator mutatorOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _of(
        context,
        listen: listen,
        aspect: NavigationUpdateAspect.currentNode,
      ).navigationController;

  /// Returns the [RouteNodeBuilder] for the current subtree.
  static RouteNodeBuilder routeNodeBuilderOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _of(
        context,
        listen: listen,
        aspect: NavigationUpdateAspect.currentNode,
      ).routeNodeBuilder;

  /// Returns the [YxNavigation] associated with the current [BuildContext].
  static YxNavigation _of(
    BuildContext context, {
    required NavigationUpdateAspect aspect,
    bool listen = true,
  }) {
    final result = _maybeOf(
      context,
      listen: listen,
      aspect: aspect,
    );
    return ArgumentError.checkNotNull(result, 'YxNavigation');
  }

  /// Returns the [YxNavigation] associated with the current [BuildContext],
  /// or `null` if there is no [YxNavigation] widget in the tree.
  static YxNavigation? _maybeOf(
    BuildContext context, {
    required NavigationUpdateAspect aspect,
    bool listen = true,
  }) {
    if (listen) {
      return InheritedModel.inheritFrom<YxNavigation>(context, aspect: aspect);
    }

    return context.getInheritedWidgetOfExactType<YxNavigation>();
  }

  @override
  bool updateShouldNotify(YxNavigation oldWidget) => true;

  @override
  bool updateShouldNotifyDependent(
    covariant YxNavigation oldWidget,
    Set<NavigationUpdateAspect> dependencies,
  ) {
    for (final dependency in dependencies) {
      switch (dependency) {
        case NavigationUpdateAspect.currentNode:
          final currentNode = _currentRouteNode;
          final oldCurrentNode = oldWidget._currentRouteNode;
          if (currentNode != null &&
              oldCurrentNode != null &&
              !currentNode.equalsBy(oldCurrentNode)) {
            return true;
          }
        case NavigationUpdateAspect.parentNode:
          final currentNode = _parentRouteNode;
          final oldCurrentNode = oldWidget._parentRouteNode;
          if (currentNode != null &&
              oldCurrentNode != null &&
              !currentNode.equalsBy(oldCurrentNode)) {
            return true;
          }
        case NavigationUpdateAspect.rootNode:
          final currentNode = _rootRouteNode;
          final oldCurrentNode = oldWidget._rootRouteNode;
          if (!currentNode.equalsBy(oldCurrentNode)) {
            return true;
          }
      }
    }

    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<RouteNode>(
          'routeNode',
          routeNode,
        ),
      )
      ..add(
        DiagnosticsProperty<RouteNode>(
          'root',
          stateManager.state,
        ),
      )
      ..add(
        DiagnosticsProperty<RouteNode>(
          'resolved',
          navigationController.state,
        ),
      )
      ..add(
        DiagnosticsProperty<RouteNode>(
          'parent',
          parentNavigationController.state,
        ),
      );
  }
}
