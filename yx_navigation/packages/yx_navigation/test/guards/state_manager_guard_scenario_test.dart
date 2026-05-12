import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/guard/guard_configuration.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

class AppRoutes {
  static const YxRoute root = YxRoute(id: 'root');
  static const YxRoute login = YxRoute(id: 'login');
  static const YxRoute shop = YxRoute(id: 'shop');
  static const YxRoute map = YxRoute(id: 'map');
}

void main() {
  late RouteNodeGuardMock guardMock;
  late RouteNodeGuardMock anotherGuardMock;

  late GuardConfiguration guardConfiguration;
  late RouteNodeStateManager actualStateManager;
  late RouteNode initialNode;

  setUpAll(registerFallbacks);

  setUp(() {
    guardMock = RouteNodeGuardMock();
    anotherGuardMock = RouteNodeGuardMock();

    initialNode = RouteNode.fromRoute(
      route: AppRoutes.root,
      children: [RouteNode.fromRoute(route: AppRoutes.login)],
    );

    guardConfiguration = GuardConfiguration(guards: [guardMock]);

    actualStateManager = RouteNodeStateManager(
      routeNode: initialNode,
      routeNodeGuard: guardConfiguration,
    );
  });

  group('GuardConfiguration', () {
    test('allows mutation when guard returns next result', () {
      // arrange
      final expectedTargetNode = RouteNode.fromRoute(route: AppRoutes.map);
      when(() => guardMock.call(any(), captureAny(), any()))
          .thenReturn(const GuardResult.next());

      // act
      actualStateManager.mutate((routeNode) => expectedTargetNode);

      // assert
      final verificationResult =
          verify(() => guardMock.call(any(), captureAny(), any()));
      final actualRoute = (verificationResult.captured.last as RouteNode).route;
      expect(actualRoute, equals(expectedTargetNode.route));
      expect(actualStateManager.state, equals(expectedTargetNode));
    });

    test('disallows mutation when guard returns cancel result', () {
      // arrange
      final expectedTargetNode = RouteNode.fromRoute(route: AppRoutes.map);
      when(() => guardMock.call(any(), any(), any())).thenReturn(
        const GuardResult.cancel(reason: 'Target route node must has root'),
      );

      // act
      actualStateManager.mutate((routeNode) => expectedTargetNode);

      // assert
      final verificationResult =
          verify(() => guardMock.call(any(), captureAny(), any()));
      final actualRoute = (verificationResult.captured.last as RouteNode).route;
      expect(actualRoute, equals(expectedTargetNode.route));
      expect(actualStateManager.state, equals(initialNode));
    });

    test('redirects target node when guard returns redirect result', () {
      // arrange
      final expectedTargetNode = RouteNode.fromRoute(route: AppRoutes.map);
      final expectedRedirectedNode =
          RouteNode.fromRoute(route: AppRoutes.login);

      when(() => guardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());
      when(
        () => guardMock.call(
          any(),
          captureAny(
            that: isA<RouteNode>().having(
              (node) => node.route,
              'Route',
              equals(expectedTargetNode.route),
            ),
          ),
          any(),
        ),
      ).thenReturn(GuardResult.redirect(target: expectedRedirectedNode));

      // act
      actualStateManager.mutate((routeNode) => expectedTargetNode);

      // assert
      final verificationResult =
          verify(() => guardMock.call(any(), captureAny(), any()));
      final actualFirstRedirectedRoute =
          (verificationResult.captured.first as RouteNode).route;
      final actualLastRedirectedRoute =
          (verificationResult.captured.last as RouteNode).route;
      expect(actualFirstRedirectedRoute, equals(expectedTargetNode.route));
      expect(actualLastRedirectedRoute, equals(expectedRedirectedNode.route));
      expect(actualStateManager.state, equals(expectedRedirectedNode));
    });

    test('applies several redirect guards one after another', () {
      // arrange
      final expectedFirstRedirectTargetNode =
          RouteNode.fromRoute(route: AppRoutes.map);
      final expectedSecondRedirectTargetNode =
          RouteNode.fromRoute(route: AppRoutes.shop);
      final expectedStartRedirectionNode =
          RouteNode.fromRoute(route: AppRoutes.login);

      when(() => guardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());
      when(
        () => guardMock.call(
          any(),
          captureAny(
            that: isA<RouteNode>().having(
              (node) => node.route,
              'Route',
              equals(expectedStartRedirectionNode.route),
            ),
          ),
          any(),
        ),
      ).thenReturn(
        GuardResult.redirect(target: expectedFirstRedirectTargetNode),
      );
      when(
        () => guardMock.call(
          any(),
          captureAny(
            that: isA<RouteNode>().having(
              (node) => node.route,
              'Route',
              equals(expectedFirstRedirectTargetNode.route),
            ),
          ),
          any(),
        ),
      ).thenReturn(
        GuardResult.redirect(target: expectedSecondRedirectTargetNode),
      );

      // act
      actualStateManager.mutate((routeNode) => expectedStartRedirectionNode);

      // assert
      final verificationResult =
          verify(() => guardMock.call(any(), captureAny(), any()));
      final actualRedirectedRoutes = verificationResult.captured
          .cast<RouteNode>()
          .map((e) => e.route)
          .toList();
      expect(
        actualRedirectedRoutes,
        orderedEquals([AppRoutes.login, AppRoutes.map, AppRoutes.shop]),
      );
      expect(
          actualStateManager.state, equals(expectedSecondRedirectTargetNode));
    });

    test('cancels mutation when max redirect attempts are reached', () {
      // arrange
      guardConfiguration = GuardConfiguration(guards: [guardMock]);
      actualStateManager = RouteNodeStateManager(
        routeNode: initialNode,
        routeNodeGuard: guardConfiguration,
      );

      final expectedFirstRedirectTargetNode =
          RouteNode.fromRoute(route: AppRoutes.map);
      final expectedSecondRedirectTargetNode =
          RouteNode.fromRoute(route: AppRoutes.shop);
      final expectedStartRedirectionNode =
          RouteNode.fromRoute(route: AppRoutes.login);

      when(() => guardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());
      when(
        () => guardMock.call(
          any(),
          captureAny(
            that: isA<RouteNode>().having(
              (node) => node.route,
              'Route',
              equals(expectedStartRedirectionNode.route),
            ),
          ),
          captureAny(),
        ),
      ).thenReturn(
        GuardResult.redirect(target: expectedFirstRedirectTargetNode),
      );
      when(
        () => guardMock.call(
          any(),
          captureAny(
            that: isA<RouteNode>().having(
              (node) => node.route,
              'Route',
              equals(expectedFirstRedirectTargetNode.route),
            ),
          ),
          captureAny(),
        ),
      ).thenReturn(
        GuardResult.redirect(target: expectedSecondRedirectTargetNode),
      );

      // act
      actualStateManager.mutate((routeNode) => expectedStartRedirectionNode);

      // assert
      expect(
          actualStateManager.state, equals(expectedSecondRedirectTargetNode));
    });

    test('disallows mutation when at least one guard cancels', () {
      // arrange
      final expectedTargetNode = RouteNode.fromRoute(route: AppRoutes.map);
      guardConfiguration =
          GuardConfiguration(guards: [guardMock, anotherGuardMock]);
      actualStateManager = RouteNodeStateManager(
        routeNode: initialNode,
        routeNodeGuard: guardConfiguration,
      );
      when(() => guardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());
      when(() => anotherGuardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.cancel());

      // act
      actualStateManager.mutate((routeNode) => expectedTargetNode);

      // assert
      expect(actualStateManager.state, equals(initialNode));
    });

    test('allows mutation when every guard allows', () {
      // arrange
      final expectedTargetNode = RouteNode.fromRoute(route: AppRoutes.map);
      guardConfiguration =
          GuardConfiguration(guards: [guardMock, anotherGuardMock]);
      actualStateManager = RouteNodeStateManager(
        routeNode: initialNode,
        routeNodeGuard: guardConfiguration,
      );
      when(() => guardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());
      when(() => anotherGuardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());

      // act
      actualStateManager.mutate((routeNode) => expectedTargetNode);

      // assert
      expect(actualStateManager.state, equals(expectedTargetNode));
    });

    test('increments redirection counter for every redirected guard call', () {
      // arrange
      final expectedFirstRedirectTargetNode =
          RouteNode.fromRoute(route: AppRoutes.map);
      final expectedSecondRedirectTargetNode =
          RouteNode.fromRoute(route: AppRoutes.shop);
      final expectedStartRedirectionNode =
          RouteNode.fromRoute(route: AppRoutes.login);

      when(() => guardMock.call(any(), any(), any()))
          .thenReturn(const GuardResult.next());
      when(
        () => guardMock.call(
          any(),
          captureAny(
            that: isA<RouteNode>().having(
              (node) => node.route,
              'Route',
              equals(expectedStartRedirectionNode.route),
            ),
          ),
          any(),
        ),
      ).thenReturn(
        GuardResult.redirect(target: expectedFirstRedirectTargetNode),
      );
      when(
        () => guardMock.call(
          any(),
          any(
            that: isA<RouteNode>().having(
              (node) => node.route,
              'Route',
              equals(expectedFirstRedirectTargetNode.route),
            ),
          ),
          captureAny(),
        ),
      ).thenReturn(
        GuardResult.redirect(target: expectedSecondRedirectTargetNode),
      );

      // act
      actualStateManager.mutate((routeNode) => expectedStartRedirectionNode);

      // assert
      expect(
          actualStateManager.state, equals(expectedSecondRedirectTargetNode));
    });
  });
}
