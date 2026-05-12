import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/router/yx_route_information_parser.dart';
import 'package:yx_navigation_flutter/src/router/yx_route_information_provider.dart';
import 'package:yx_navigation_flutter/src/router/yx_router_config.dart';
import 'package:yx_navigation_flutter/src/router/yx_router_delegate.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(registerFallbacks);

  YxRouterDelegate buildDelegate() {
    final stateManager = RouteNodeStateManager(routeNode: makeNode());
    addTearDown(stateManager.close);
    return YxRouterDelegate(
      stateManager: stateManager,
      routeNodeBuilder: RouteNodeBuilderMock(),
    );
  }

  group('YxRouterConfig', () {
    test('accepts both-null parser+provider pair without triggering the assert',
        () {
      // arrange
      final delegate = buildDelegate();
      addTearDown(delegate.dispose);

      // act/assert
      expect(
        () => YxRouterConfig(
          backButtonDispatcher: RootBackButtonDispatcher(),
          routerDelegate: delegate,
        ),
        returnsNormally,
      );
    });

    test('throws AssertionError when parser is provided but provider is null',
        () {
      // arrange
      final delegate = buildDelegate();
      addTearDown(delegate.dispose);
      final parserStateManager = RouteNodeStateManager(routeNode: makeNode());
      addTearDown(parserStateManager.close);
      final parser = YxRouteInformationParser(
        stateManager: parserStateManager,
        serialization: const PrettyUriStateSerialization(),
        fallbackBuilder: const RouteInformationParserFallbackBuilderImpl(),
      );

      // act/assert
      expect(
        () => YxRouterConfig(
          backButtonDispatcher: RootBackButtonDispatcher(),
          routerDelegate: delegate,
          routeInformationParser: parser,
        ),
        throwsAssertionError,
      );
    });

    test('throws AssertionError when provider is provided but parser is null',
        () {
      // arrange
      final delegate = buildDelegate();
      addTearDown(delegate.dispose);
      final provider = YxRouteInformationProvider(
        serialization: const PrettyUriStateSerialization(),
      );
      addTearDown(provider.dispose);

      // act/assert
      expect(
        () => YxRouterConfig(
          backButtonDispatcher: RootBackButtonDispatcher(),
          routerDelegate: delegate,
          routeInformationProvider: provider,
        ),
        throwsAssertionError,
      );
    });
  });
}
