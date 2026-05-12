import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../base/builder/route_indexed_stack_builder.dart';
import '../base/route_node_builder.dart';
import '../extensions/build_context_extension.dart';
import '../router/active_route_controller_provider.dart';

class RouteNodeIndexedStack extends StatefulWidget {
  final RouteNodeIndexedBuilder indexedStackBuilder;
  final RouteNode routeNode;

  const RouteNodeIndexedStack({
    required this.routeNode,
    required this.indexedStackBuilder,
    super.key,
  });

  @override
  State<RouteNodeIndexedStack> createState() => _RouteNodeIndexedStackState();
}

class _RouteNodeIndexedStackState extends State<RouteNodeIndexedStack> {
  late final RouteNodeStateManager _stateManager;
  late final RouteNodeBuilder _routeNodeBuilder;
  late ActiveRouteController _activeRouteController;
  late RouteNodeResolver _routeNodeResolver;
  late NavigationController _navigationController;

  void _createNavigationController() {
    _routeNodeResolver = RouteNodeResolver.full(
      route: widget.routeNode.route,
      arguments: widget.routeNode.arguments,
    );
    _navigationController = NavigationController.node(
      stateManager: _stateManager,
      nodeResolver: _routeNodeResolver,
    );
    _activeRouteController = _navigationController;
  }

  @override
  void initState() {
    super.initState();
    _stateManager = context.stateManager;
    _routeNodeBuilder = context.routeNodeBuilder;
    _createNavigationController();
  }

  @override
  Widget build(BuildContext context) {
    final activeRoute = _activeRouteController.activeRoute;
    final routeNodes = widget.routeNode.children
        .sorted(RouteNodeComparator.compareByRoute)
        .toList(growable: false);
    final activeIndex = activeRoute != null
        ? routeNodes.map((e) => e.route).toList().indexOf(activeRoute)
        : 0;

    final bodyWidget = IndexedStack(
      index: activeIndex,
      children: _buildChildren(context, routeNodes: routeNodes),
    );

    return ActiveRouteControllerProvider(
      controller: _activeRouteController,
      child: Builder(
        builder: (context) => widget.indexedStackBuilder(
          context,
          widget.routeNode,
          bodyWidget,
          _activeRouteController,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant RouteNodeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isRouteNodeEquals = widget.routeNode.equalsBy(
      oldWidget.routeNode,
      equality: const RouteNodeEquality.routeAndArguments(),
    );

    if (!isRouteNodeEquals) {
      _navigationController.close();
      _createNavigationController();
    }
  }

  @override
  void dispose() {
    _navigationController.close();
    super.dispose();
  }

  List<Widget> _buildChildren(
    BuildContext context, {
    required Iterable<RouteNode> routeNodes,
  }) {
    if (routeNodes.isNotEmpty) {
      return routeNodes.mapIndexed((index, node) {
        final routeDeclarationWidget =
            _routeNodeBuilder.buildWidget(context, node);

        final hasExplicitActiveRoute =
            _activeRouteController.activeRoute != null;
        final isRouteActive = hasExplicitActiveRoute
            ? _activeRouteController.isRouteActive(node.route)
            : index == 0;

        return ActiveRouteControllerProvider.branch(
          route: node.route,
          child: Offstage(
            offstage: !isRouteActive,
            child: TickerMode(
              enabled: isRouteActive,
              child: routeDeclarationWidget,
            ),
          ),
        );
      }).toList();
    } else {
      return [
        _routeNodeBuilder.emptyWidgetBuilder(context, widget.routeNode),
      ];
    }
  }
}
