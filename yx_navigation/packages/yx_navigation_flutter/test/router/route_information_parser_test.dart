import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/router/deeplink/deeplink_handler_observer.dart';
import 'package:yx_navigation_flutter/src/router/yx_route_information_parser.dart';

import 'deeplink/mock_deeplink_handler.dart';
import 'deeplink/mock_deeplink_handler_observer.dart';
import 'mock_platform_state_serialization.dart';
import 'mock_route_information_parser_fallback_builder.dart';

class AppRoutes {
  static const YxRoute root = YxRoute(id: 'root');
  static const YxRoute home = YxRoute(id: 'home');
  static const YxRoute settings = YxRoute(id: 'settings');
  static const YxRoute orderDetails = YxRoute(id: 'order_details');
}

void main() {
  late MockDeeplinkHandler mockDeeplinkHandler;
  late MockPlatformStateSerialization mockSerialization;
  late MockRouteInformationParserFallbackBuilder mockFallbackBuilder;
  late RouteNodeStateManager stateManager;
  late RouteNode initialNode;

  setUp(() {
    mockDeeplinkHandler = MockDeeplinkHandler();
    mockSerialization = MockPlatformStateSerialization();
    mockFallbackBuilder = MockRouteInformationParserFallbackBuilder();

    initialNode = RouteNode.fromRoute(
      route: AppRoutes.root,
      children: [RouteNode.fromRoute(route: AppRoutes.home)],
    );

    stateManager = RouteNodeStateManager(routeNode: initialNode);
  });

  tearDown(() async {
    await stateManager.close();
  });

  YxRouteInformationParser createParser({
    DeeplinkHandler? deeplinkHandler,
    DeeplinkHandlerObserver? deeplinkHandlerObserver,
  }) =>
      YxRouteInformationParser(
        stateManager: stateManager,
        serialization: mockSerialization,
        fallbackBuilder: mockFallbackBuilder,
        deeplinkHandler: deeplinkHandler,
        deeplinkHandlerObserver: deeplinkHandlerObserver,
      );

  group('YxRouteInformationParser with DeeplinkHandler', () {
    group('when DeeplinkHandler returns navigate result', () {
      test('returns the node emitted by DeeplinkHandler', () async {
        // arrange
        final expectedNode = RouteNode.fromRoute(
          route: AppRoutes.root,
          children: [
            RouteNode.fromRoute(route: AppRoutes.home),
            RouteNode.fromRoute(
              route: AppRoutes.orderDetails,
              arguments: const {'orderId': '123'},
            ),
          ],
        );
        mockDeeplinkHandler.onHandle =
            (uri, currentState) => DeeplinkHandlerResult.navigate(expectedNode);
        final parser = createParser(deeplinkHandler: mockDeeplinkHandler);
        final routeInformation = RouteInformation(
          uri: Uri.parse('/order_details?id=123'),
        );

        // act
        final result = await parser.parseRouteInformation(routeInformation);

        // assert
        expect(result, expectedNode);
        expect(mockSerialization.parseCalls, isEmpty);
      });

      test('passes current navigation state to DeeplinkHandler', () async {
        // arrange
        final navigatedNode = RouteNode.fromRoute(
          route: AppRoutes.root,
          children: [
            RouteNode.fromRoute(route: AppRoutes.settings),
          ],
        );
        mockDeeplinkHandler.onHandle = (uri, currentState) =>
            DeeplinkHandlerResult.navigate(navigatedNode);
        final parser = createParser(deeplinkHandler: mockDeeplinkHandler);

        // act
        await parser.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/settings')),
        );

        // assert
        expect(mockDeeplinkHandler.handleCalls.length, 1);
        expect(
          mockDeeplinkHandler.handleCalls.first.$1,
          Uri.parse('/settings'),
        );
        expect(mockDeeplinkHandler.handleCalls.first.$2, initialNode);
      });
    });

    group('when DeeplinkHandler returns handled result', () {
      test('returns current state without navigation', () async {
        // arrange
        mockDeeplinkHandler.onHandle =
            (uri, currentState) => const DeeplinkHandlerResult.handled();
        final parser = createParser(deeplinkHandler: mockDeeplinkHandler);
        final routeInformation = RouteInformation(
          uri: Uri.parse('/alert?msg=Hello'),
        );

        // act
        final result = await parser.parseRouteInformation(routeInformation);

        // assert
        expect(result, stateManager.state);
        expect(mockDeeplinkHandler.handleCalls.length, 1);
        expect(mockSerialization.parseCalls, isEmpty);
      });
    });

    group('when DeeplinkHandler returns null (not handled)', () {
      test('falls back to serialization parsing', () async {
        // arrange
        final expectedNode = RouteNode.fromRoute(
          route: AppRoutes.root,
          children: [RouteNode.fromRoute(route: AppRoutes.settings)],
        );
        mockDeeplinkHandler.onHandle = (uri, currentState) => null;
        mockSerialization.onParse = (uri) => expectedNode;
        final parser = createParser(deeplinkHandler: mockDeeplinkHandler);
        final routeInformation = RouteInformation(
          uri: Uri.parse('/root/.settings'),
        );

        // act
        final result = await parser.parseRouteInformation(routeInformation);

        // assert
        expect(result, expectedNode);
        expect(mockDeeplinkHandler.handleCalls.length, 1);
        expect(mockSerialization.parseCalls.length, 1);
      });
    });

    group('when DeeplinkHandler throws an error', () {
      test('should fallback to serialization parsing', () async {
        // arrange
        final expectedNode = RouteNode.fromRoute(
          route: AppRoutes.root,
          children: [RouteNode.fromRoute(route: AppRoutes.home)],
        );
        mockDeeplinkHandler.onHandle = (uri, currentState) {
          throw Exception('Deeplink handler error');
        };
        mockSerialization.onParse = (uri) => expectedNode;
        final parser = createParser(deeplinkHandler: mockDeeplinkHandler);
        final routeInformation = RouteInformation(
          uri: Uri.parse('/crash'),
        );

        // act
        final result = await parser.parseRouteInformation(routeInformation);

        // assert
        expect(result, expectedNode);
        expect(mockDeeplinkHandler.handleCalls.length, 1);
        expect(mockSerialization.parseCalls.length, 1);
      });
    });

    group('when DeeplinkHandler is null', () {
      test('should use serialization parsing directly', () async {
        // arrange
        final expectedNode = RouteNode.fromRoute(
          route: AppRoutes.root,
          children: [RouteNode.fromRoute(route: AppRoutes.settings)],
        );
        mockSerialization.onParse = (uri) => expectedNode;
        final parser = createParser();
        final routeInformation = RouteInformation(
          uri: Uri.parse('/root/.settings'),
        );

        // act
        final result = await parser.parseRouteInformation(routeInformation);

        // assert
        expect(result, expectedNode);
        expect(mockSerialization.parseCalls.length, 1);
      });
    });

    group('when serialization fails', () {
      test('should use fallback builder', () async {
        // arrange
        mockDeeplinkHandler.onHandle = (uri, currentState) => null;
        mockSerialization.onParse = (uri) {
          throw const FormatException('Invalid URI format');
        };
        mockFallbackBuilder.onBuildFallback = ({
          required stateManager,
          required routeInformation,
          serializationError,
        }) async =>
            initialNode;
        final parser = createParser(deeplinkHandler: mockDeeplinkHandler);
        final routeInformation = RouteInformation(
          uri: Uri.parse('/invalid/uri'),
        );

        // act
        final result = await parser.parseRouteInformation(routeInformation);

        // assert
        expect(result, initialNode);
        expect(mockFallbackBuilder.buildFallbackCalls.length, 1);
        expect(
          mockFallbackBuilder.buildFallbackCalls.first.stateManager,
          stateManager,
        );
        expect(
          mockFallbackBuilder.buildFallbackCalls.first.routeInformation,
          routeInformation,
        );
        expect(
          mockFallbackBuilder.buildFallbackCalls.first.serializationError,
          isA<FormatException>(),
        );
      });
    });
  });

  group('DeeplinkHandlerObserver', () {
    late MockDeeplinkHandlerObserver mockObserver;

    setUp(() {
      mockObserver = MockDeeplinkHandlerObserver();
    });

    test('should call onDeeplinkReceived when deeplink is received', () async {
      // arrange
      mockDeeplinkHandler.onHandle = (uri, currentState) => null;
      mockSerialization.onParse = (uri) => initialNode;
      final parser = createParser(
        deeplinkHandler: mockDeeplinkHandler,
        deeplinkHandlerObserver: mockObserver,
      );

      // act
      await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/test')),
      );

      // assert
      expect(mockObserver.receivedCalls.length, 1);
      expect(mockObserver.receivedCalls.first.$1, Uri.parse('/test'));
      expect(mockObserver.receivedCalls.first.$2, initialNode);
    });

    test('should call onDeeplinkNavigate when handler returns navigate',
        () async {
      // arrange
      final targetNode = RouteNode.fromRoute(route: AppRoutes.settings);
      mockDeeplinkHandler.onHandle =
          (uri, currentState) => DeeplinkHandlerResult.navigate(targetNode);
      final parser = createParser(
        deeplinkHandler: mockDeeplinkHandler,
        deeplinkHandlerObserver: mockObserver,
      );

      // act
      await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/settings')),
      );

      // assert
      expect(mockObserver.navigateCalls.length, 1);
      expect(mockObserver.navigateCalls.first.$1, Uri.parse('/settings'));
      expect(mockObserver.navigateCalls.first.$2, initialNode);
      expect(mockObserver.navigateCalls.first.$3, targetNode);
    });

    test('should call onDeeplinkHandled when handler returns handled',
        () async {
      // arrange
      mockDeeplinkHandler.onHandle =
          (uri, currentState) => const DeeplinkHandlerResult.handled();
      final parser = createParser(
        deeplinkHandler: mockDeeplinkHandler,
        deeplinkHandlerObserver: mockObserver,
      );

      // act
      await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/alert')),
      );

      // assert
      expect(mockObserver.handledCalls.length, 1);
      expect(mockObserver.handledCalls.first.$1, Uri.parse('/alert'));
      expect(mockObserver.handledCalls.first.$2, initialNode);
    });

    test('should call onDeeplinkSkipped when handler returns null', () async {
      // arrange
      mockDeeplinkHandler.onHandle = (uri, currentState) => null;
      mockSerialization.onParse = (uri) => initialNode;
      final parser = createParser(
        deeplinkHandler: mockDeeplinkHandler,
        deeplinkHandlerObserver: mockObserver,
      );

      // act
      await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/unknown')),
      );

      // assert
      expect(mockObserver.skippedCalls.length, 1);
      expect(mockObserver.skippedCalls.first.$1, Uri.parse('/unknown'));
      expect(mockObserver.skippedCalls.first.$2, initialNode);
    });

    test('should call onDeeplinkError when handler throws', () async {
      // arrange
      mockDeeplinkHandler.onHandle = (uri, currentState) {
        throw Exception('Test error');
      };
      mockSerialization.onParse = (uri) => initialNode;
      final parser = createParser(
        deeplinkHandler: mockDeeplinkHandler,
        deeplinkHandlerObserver: mockObserver,
      );

      // act
      await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/crash')),
      );

      // assert
      expect(mockObserver.errorCalls.length, 1);
      expect(mockObserver.errorCalls.first.$1, Uri.parse('/crash'));
      expect(mockObserver.errorCalls.first.$2, initialNode);
      expect(mockObserver.errorCalls.first.$3, isA<Exception>());
      expect(mockObserver.errorCalls.first.$4, isA<StackTrace>());
    });

    test('should not call observer methods when no handler is configured',
        () async {
      // arrange
      mockSerialization.onParse = (uri) => initialNode;
      final parser = createParser(
        deeplinkHandlerObserver: mockObserver,
      );

      // act
      await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/test')),
      );

      // assert
      expect(mockObserver.receivedCalls, isEmpty);
      expect(mockObserver.navigateCalls, isEmpty);
      expect(mockObserver.handledCalls, isEmpty);
      expect(mockObserver.skippedCalls, isEmpty);
      expect(mockObserver.errorCalls, isEmpty);
    });
  });

  group('restoreRouteInformation / parseRouteInformation round-trip', () {
    test(
        'parseRouteInformation then restoreRouteInformation yields a URI that '
        're-parses to the same node', () async {
      // arrange: serialization parses `/settings` to `settings` node and
      // converts nodes back to their URI. Compose a reversible pair.
      final declaredNode = RouteNode.fromRoute(route: AppRoutes.settings);
      mockSerialization.onParse = (uri) => declaredNode;
      // ignore: cascade_invocations
      mockSerialization.onConvert = (node) => Uri.parse('/${node.route.id}');

      final parser = createParser();
      final routeInformation = RouteInformation(uri: Uri.parse('/settings'));

      // act
      final parsed = await parser.parseRouteInformation(routeInformation);
      final restored = parser.restoreRouteInformation(parsed);

      // assert: restoreRouteInformation returns a RouteInformation wrapper.
      expect(restored, isA<RouteInformation>());
      // And the inverse cycle (convert then parse) gives us back an
      // equivalent node — this is the round-trip contract.
      final reParsed = await parser.parseRouteInformation(restored!);
      expect(reParsed, equals(parsed));
    });
  });
}
