import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/router/yx_route_information_provider.dart';

import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  TestWidgetsFlutterBinding.ensureInitialized();

  group('YxRouteInformationProvider', () {
    test('initial value comes from platform default route', () {
      // arrange/act
      final actualProvider = YxRouteInformationProvider(
        serialization: const PrettyUriStateSerialization(),
      );
      addTearDown(actualProvider.dispose);

      // assert
      expect(actualProvider.value, isA<RouteInformation>());
    });

    test('routerReportsNewRouteInformation updates value', () {
      // arrange
      final actualProvider = YxRouteInformationProvider(
        serialization: const PrettyUriStateSerialization(),
      );
      addTearDown(actualProvider.dispose);
      final expectedInfo = RouteInformation(uri: Uri.parse('/home/details'));

      // act
      actualProvider.routerReportsNewRouteInformation(expectedInfo);

      // assert
      expect(actualProvider.value, same(expectedInfo));
    });

    group('routerReportsNewRouteInformation — platform channel contract', () {
      final recordedCalls = <MethodCall>[];
      final binding = TestDefaultBinaryMessengerBinding.instance;

      setUp(() {
        recordedCalls.clear();
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            recordedCalls.add(call);
            return null;
          },
        );
      });

      tearDown(() {
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          null,
        );
      });

      MethodCall? lastRouteUpdate() => recordedCalls.lastWhere(
            (c) => c.method == 'routeInformationUpdated',
            orElse: () => const MethodCall('__none__'),
          );

      test(
          'neglect reporting type sends a replace=true message to the platform',
          () {
        // arrange
        final actualProvider = YxRouteInformationProvider(
          serialization: const PrettyUriStateSerialization(),
        );
        addTearDown(actualProvider.dispose);
        final expectedInfo = RouteInformation(uri: Uri.parse('/home'));

        // act
        actualProvider.routerReportsNewRouteInformation(
          expectedInfo,
          type: RouteInformationReportingType.neglect,
        );

        // assert
        final update = lastRouteUpdate();
        expect(update?.method, equals('routeInformationUpdated'));
        final arguments = (update!.arguments as Map?)?.cast<String, Object?>();
        expect(arguments?['replace'], isTrue);
        expect(actualProvider.value, same(expectedInfo));
      });

      test(
          'navigate reporting type with a changed uri sends replace=false '
          '(new history entry) to the platform', () {
        // arrange
        final actualProvider = YxRouteInformationProvider(
          serialization: const PrettyUriStateSerialization(),
        );
        addTearDown(actualProvider.dispose);
        final expectedInfo = RouteInformation(uri: Uri.parse('/home/details'));

        // act
        actualProvider.routerReportsNewRouteInformation(
          expectedInfo,
          type: RouteInformationReportingType.navigate,
        );

        // assert
        final update = lastRouteUpdate();
        expect(update?.method, equals('routeInformationUpdated'));
        final arguments = (update!.arguments as Map?)?.cast<String, Object?>();
        expect(arguments?['replace'], isFalse);
      });

      test(
          'none reporting type with a changed uri sends replace=false '
          '(treated like navigate)', () {
        // arrange
        final actualProvider = YxRouteInformationProvider(
          serialization: const PrettyUriStateSerialization(),
        );
        addTearDown(actualProvider.dispose);
        final expectedInfo = RouteInformation(uri: Uri.parse('/settings'));

        // act
        actualProvider.routerReportsNewRouteInformation(expectedInfo);

        // assert
        final update = lastRouteUpdate();
        expect(update?.method, equals('routeInformationUpdated'));
        final arguments = (update!.arguments as Map?)?.cast<String, Object?>();
        expect(arguments?['replace'], isFalse);
      });
    });

    test('didPushRouteInformation short-circuits when info is identical',
        () async {
      // arrange
      final notifications = <void>[];
      final actualProvider = YxRouteInformationProvider(
        serialization: const PrettyUriStateSerialization(),
      )
        ..addListener(() {})
        ..addListener(() => notifications.add(null));
      addTearDown(actualProvider.dispose);
      final initialInfo = actualProvider.value;

      // act
      final actualResult =
          await actualProvider.didPushRouteInformation(initialInfo);

      // assert
      expect(actualResult, isTrue);
      expect(notifications, isEmpty);
    });

    test('didPushRouteInformation notifies listeners when value changes',
        () async {
      // arrange
      final actualProvider = YxRouteInformationProvider(
        serialization: const PrettyUriStateSerialization(),
      );
      addTearDown(actualProvider.dispose);
      var notified = 0;
      actualProvider.addListener(() => notified++);
      final expectedInfo = RouteInformation(uri: Uri.parse('/new'));

      // act
      final actualResult =
          await actualProvider.didPushRouteInformation(expectedInfo);

      // assert
      expect(actualResult, isTrue);
      expect(notified, equals(1));
      expect(actualProvider.value, same(expectedInfo));
    });

    test('dispose removes listeners gracefully', () {
      // arrange
      final actualProvider = YxRouteInformationProvider(
        serialization: const PrettyUriStateSerialization(),
      );

      // act/assert
      expect(() => actualProvider.dispose(), returnsNormally);
    });

    test(
        'didPushRouteInformation triggers assert(hasListeners) when nobody is '
        'listening', () {
      // arrange
      final actualProvider = YxRouteInformationProvider(
        serialization: const PrettyUriStateSerialization(),
      );
      addTearDown(actualProvider.dispose);
      final expectedInfo = RouteInformation(uri: Uri.parse('/someroute'));

      // act/assert: contract — asserts hasListeners.
      expect(
        () => actualProvider.didPushRouteInformation(expectedInfo),
        throwsAssertionError,
      );
    });

    test('initialRouteInformation returns Uri wrapper even on bad input', () {
      // act
      final actualInfo = YxRouteInformationProvider.initialRouteInformation();

      // assert
      expect(actualInfo, isA<RouteInformation>());
    });
  });
}
