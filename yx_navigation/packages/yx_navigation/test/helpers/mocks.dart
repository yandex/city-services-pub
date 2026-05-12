import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/base/route_node_resolver.dart';
import 'package:yx_navigation/src/base/route_observer/route_observer.dart';
import 'package:yx_navigation/src/deeplink/deeplink_handler.dart';
import 'package:yx_navigation/src/guard/guard_context.dart';
import 'package:yx_navigation/src/guard/guard_observer.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';
import 'package:yx_navigation/src/guard/route_node_guard.dart';
import 'package:yx_navigation/src/state/base/state_manager_observer.dart';

class RouteNodeGuardMock extends Mock implements RouteNodeGuard {}

class RouteNodeResolverMock extends Mock implements RouteNodeResolver {}

class DeeplinkHandlerMock extends Mock implements DeeplinkHandler {}

class StateManagerObserverMock extends Mock implements StateManagerObserver {}

class RouteObserverMock extends Mock implements YxRouteObserver {}

class GuardObserverMock extends Mock implements GuardObserver {}

/// No-op guard used as a fallback value and as a placeholder in tests that
/// need a real (non-mock) [RouteNodeGuard] instance.
class RouteNodeGuardFake implements RouteNodeGuard {
  const RouteNodeGuardFake();

  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
  ) =>
      const GuardResult.next();
}
