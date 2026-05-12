import 'dart:async';

import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_navigator.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_node_resolver.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';
import 'package:yx_navigation/src/guard/guard_configuration.dart';
import 'package:yx_navigation/src/guard/guard_context.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';
import 'package:yx_navigation/src/guard/guard_sync.dart';
import 'package:yx_navigation/src/guard/route_node_guard.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

import '../helpers/async.dart';

/// Holds the state of an incoming order.
class IncomeOrderStateManager {
  bool _hasIncomeOrder = false;
  bool get hasIncomeOrder => _hasIncomeOrder;

  final _hasIncomeOrderController = StreamController<bool>.broadcast();
  Stream<bool> get hasIncomeOrderStream => _hasIncomeOrderController.stream;

  IncomeOrderStateManager();

  void setHasIncomeOrder(bool value) {
    _hasIncomeOrder = value;
    _hasIncomeOrderController.add(_hasIncomeOrder);
  }

  Future<void> close() async {
    await _hasIncomeOrderController.close();
  }
}

/// Notifies navigation that there is an incoming order and the taxi tab
/// must become active.
class IncomeOrderInteractor {
  final IncomeOrderStateManager _stateManager;
  final GuardSync _guardSync;

  StreamSubscription<bool>? _onHasIncomeOrderSub;

  IncomeOrderInteractor({
    required IncomeOrderStateManager stateManager,
    required GuardSync guardSync,
  })  : _stateManager = stateManager,
        _guardSync = guardSync;

  Future<void> init() async {
    _onHasIncomeOrderSub ??= _stateManager.hasIncomeOrderStream.listen(
      _onHasIncomeOrder,
    );
    _onHasIncomeOrder(_stateManager.hasIncomeOrder);
  }

  Future<void> close() async {
    await _onHasIncomeOrderSub?.cancel();
    _onHasIncomeOrderSub = null;
  }

  void _onHasIncomeOrder(bool hasIncomeOrder) {
    if (!hasIncomeOrder) {
      return;
    }

    _guardSync.add(const GuardSyncReason(message: 'Has income order'));
  }
}

/// Forces the taxi tab to become active when there is an incoming order.
class IncomeOrderGuard implements RouteNodeGuard {
  final YxRoute _tabRoute;
  final YxRoute _taxiRoute;
  final IncomeOrderStateManager _stateManager;

  IncomeOrderGuard({
    required YxRoute tabRoute,
    required YxRoute taxiRoute,
    required IncomeOrderStateManager stateManager,
  })  : _tabRoute = tabRoute,
        _taxiRoute = taxiRoute,
        _stateManager = stateManager;

  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
  ) {
    final mutableTarget = target.toMutable();
    final tabRouteNode = mutableTarget.findByRoute(_tabRoute);

    if (tabRouteNode == null) {
      return const GuardResult.next();
    }

    final hasIncomeOrder = _stateManager.hasIncomeOrder;
    if (!hasIncomeOrder) {
      return const GuardResult.next();
    }

    final shouldUpdate = shouldUpdateRoute(tabRouteNode);
    if (!shouldUpdate) {
      return const GuardResult.next();
    }

    tabRouteNode.addOrMoveToEnd(_taxiRoute.toMutableNode());

    return GuardResult.redirect(target: mutableTarget);
  }

  /// Returns true when the active tab must be updated to taxi.
  bool shouldUpdateRoute(RouteNode target) {
    final currentRoute = target.children.lastOrNull?.route;
    if (currentRoute == _taxiRoute) {
      return false;
    }
    return true;
  }
}

/// Bundle of objects a scenario test needs; built inside [_buildScenario]
/// within the fakeAsync zone so that broadcast controllers schedule their
/// microtasks in the fake zone.
class _Scenario {
  final GuardSync guardSync;
  final IncomeOrderStateManager incomeOrderStateManager;
  final IncomeOrderInteractor incomeOrderInteractor;
  final RouteNodeStateManager stateManager;
  final NavigationController tabNavigationController;
  final List<YxRoute?> actualCurrentTabRoutes;
  final List<RouteNode?> actualRouteNodes;
  final StreamSubscription<YxRoute?> activeRouteSub;
  final StreamSubscription<RouteNode?> stateSub;

  _Scenario({
    required this.guardSync,
    required this.incomeOrderStateManager,
    required this.incomeOrderInteractor,
    required this.stateManager,
    required this.tabNavigationController,
    required this.actualCurrentTabRoutes,
    required this.actualRouteNodes,
    required this.activeRouteSub,
    required this.stateSub,
  });

  Future<void> dispose() async {
    await activeRouteSub.cancel();
    await stateSub.cancel();
    await incomeOrderInteractor.close();
    await tabNavigationController.close();
    await stateManager.close();
    await guardSync.close();
    await incomeOrderStateManager.close();
  }
}

void main() {
  const tab = YxRoute(id: 'tab');
  const taxi = YxRoute(id: 'taxi');
  const profile = YxRoute(id: 'profile');

  /// Builds a fully-wired scenario inside the fakeAsync zone.
  /// Tests MUST call [_Scenario.dispose] before returning (followed by
  /// `fa.flushMicrotasks()`) to avoid leaking controllers across tests.
  _Scenario buildScenario() {
    final guardSync = GuardSync();
    final incomeOrderStateManager = IncomeOrderStateManager();
    final incomeOrderInteractor = IncomeOrderInteractor(
      stateManager: incomeOrderStateManager,
      guardSync: guardSync,
    )..init();

    final taxiTabGuard = IncomeOrderGuard(
      tabRoute: tab,
      taxiRoute: taxi,
      stateManager: incomeOrderStateManager,
    );

    final tabNode = tab.toMutableNode(
      children: [
        RouteNode.fromRoute(route: taxi),
        RouteNode.fromRoute(route: profile),
      ],
    );
    final routeNode = RouteNode.fromRoute(
      route: const YxRoute(id: 'root'),
      children: [tabNode],
    );
    final guardConfiguration = GuardConfiguration(guards: [taxiTabGuard]);
    final stateManager = RouteNodeStateManager(
      routeNode: routeNode,
      routeNodeGuard: guardConfiguration,
      guardSync: guardSync,
    );
    final tabNavigationController = NavigationController.node(
      stateManager: stateManager,
      nodeResolver: const RouteNodeResolver.id(route: tab),
    );

    final actualCurrentTabRoutes = <YxRoute?>[];
    final activeRouteSub = tabNavigationController.activeRouteStream.listen(
      actualCurrentTabRoutes.add,
    );
    final actualRouteNodes = <RouteNode?>[];
    final stateSub =
        tabNavigationController.stream.listen(actualRouteNodes.add);

    return _Scenario(
      guardSync: guardSync,
      incomeOrderStateManager: incomeOrderStateManager,
      incomeOrderInteractor: incomeOrderInteractor,
      stateManager: stateManager,
      tabNavigationController: tabNavigationController,
      actualCurrentTabRoutes: actualCurrentTabRoutes,
      actualRouteNodes: actualRouteNodes,
      activeRouteSub: activeRouteSub,
      stateSub: stateSub,
    );
  }

  group('IncomeOrderGuard', () {
    testAsync('redirects tab to taxi when income order arrives', (fa) {
      // arrange
      final scenario = buildScenario();
      fa.flushMicrotasks();

      // sanity: initial state — profile is active, no income order.
      expect(scenario.tabNavigationController.isRouteActive(profile), isTrue);
      expect(scenario.incomeOrderStateManager.hasIncomeOrder, isFalse);

      // act: income order arrives.
      scenario.incomeOrderStateManager.setHasIncomeOrder(true);
      fa.flushMicrotasks();

      // assert: taxi became active and navigation state emitted exactly once.
      expect(scenario.incomeOrderStateManager.hasIncomeOrder, isTrue);
      expect(scenario.actualRouteNodes, hasLength(1));
      expect(scenario.actualCurrentTabRoutes, hasLength(1));
      expect(scenario.actualCurrentTabRoutes.first, equals(taxi));
      expect(scenario.actualRouteNodes.firstOrNull?.children, hasLength(2));
      expect(scenario.tabNavigationController.isRouteActive(taxi), isTrue);

      // teardown
      scenario.dispose();
      fa.flushMicrotasks();
    });

    testAsync('blocks switching away from taxi while income order is active',
        (fa) {
      // arrange: start with taxi active (income order has already arrived).
      final scenario = buildScenario();
      fa.flushMicrotasks();
      scenario.incomeOrderStateManager.setHasIncomeOrder(true);
      fa.flushMicrotasks();
      expect(scenario.tabNavigationController.isRouteActive(taxi), isTrue);

      // act: attempt to switch away from taxi while income order is active.
      scenario.tabNavigationController.setActiveRoute(profile);
      fa.flushMicrotasks();

      // assert: switch was blocked — taxi stays active, no extra emissions
      // beyond the initial redirect.
      expect(scenario.actualRouteNodes, hasLength(1));
      expect(scenario.actualCurrentTabRoutes, hasLength(1));
      expect(scenario.tabNavigationController.isRouteActive(profile), isFalse);
      expect(scenario.tabNavigationController.isRouteActive(taxi), isTrue);

      // teardown
      scenario.dispose();
      fa.flushMicrotasks();
    });

    testAsync('allows switching to another tab after income order is cleared',
        (fa) {
      // arrange: start with taxi active, then clear the income order.
      final scenario = buildScenario();
      fa.flushMicrotasks();
      scenario.incomeOrderStateManager.setHasIncomeOrder(true);
      fa.flushMicrotasks();
      scenario.incomeOrderStateManager.setHasIncomeOrder(false);
      fa.flushMicrotasks();

      // sanity: taxi still active until user switches away.
      expect(scenario.incomeOrderStateManager.hasIncomeOrder, isFalse);
      expect(scenario.tabNavigationController.isRouteActive(taxi), isTrue);

      // act: switch to profile now that income order is clear.
      scenario.tabNavigationController.setActiveRoute(profile);
      fa.flushMicrotasks();

      // assert: profile is active; exactly two navigation events and two
      // active-route events have been emitted across the scenario (taxi
      // redirect + profile switch).
      expect(scenario.actualRouteNodes, hasLength(2));
      expect(scenario.actualCurrentTabRoutes, hasLength(2));
      expect(
        scenario.actualCurrentTabRoutes,
        equals(<YxRoute?>[taxi, profile]),
      );
      expect(scenario.tabNavigationController.isRouteActive(profile), isTrue);
      expect(scenario.tabNavigationController.isRouteActive(taxi), isFalse);

      // teardown
      scenario.dispose();
      fa.flushMicrotasks();
    });
  });
}
