import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/route_node_builder.dart';

class RouteNodeGuardMock extends Mock implements RouteNodeGuard {}

class RouteNodeResolverMock extends Mock implements RouteNodeResolver {}

class DeeplinkHandlerMock extends Mock implements DeeplinkHandler {}

class StateManagerObserverMock extends Mock implements StateManagerObserver {}

class RouteObserverMock extends Mock implements YxRouteObserver {}

class GuardObserverMock extends Mock implements GuardObserver {}

class MockBuildContext extends Mock implements BuildContext {}

class NavigationControllerMock extends Mock implements NavigationController {}

class RouteNodeBuilderMock extends Mock implements RouteNodeBuilder {}
