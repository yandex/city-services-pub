import 'package:test/test.dart';
import 'package:yx_navigation/src/late_initialization/late_init_guard_configuration.dart';

import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('LateInitGuardConfiguration', () {
    test('returns only base guards when nothing is attached', () {
      // arrange
      final baseGuard = RouteNodeGuardMock();
      final actualConfig = LateInitGuardConfiguration(guards: [baseGuard]);

      // assert
      expect(actualConfig.guards, orderedEquals(<Object>[baseGuard]));
    });

    test('attach merges module guards with base guards', () {
      // arrange/act
      final baseGuard = RouteNodeGuardMock();
      final moduleGuard = RouteNodeGuardMock();
      final actualConfig = LateInitGuardConfiguration(guards: [baseGuard])
        ..attach('module', [moduleGuard]);

      // assert
      expect(
        actualConfig.guards,
        orderedEquals(<Object>[baseGuard, moduleGuard]),
      );
    });

    test('attach throws StateError when the name is already attached', () {
      // arrange
      final actualConfig = LateInitGuardConfiguration()
        ..attach('module', [RouteNodeGuardMock()]);

      // act & assert
      expect(
        () => actualConfig.attach('module', [RouteNodeGuardMock()]),
        throwsStateError,
      );
    });

    test('detach removes previously attached guards', () {
      // arrange/act
      final baseGuard = RouteNodeGuardMock();
      final moduleGuard = RouteNodeGuardMock();
      final actualConfig = LateInitGuardConfiguration(guards: [baseGuard])
        ..attach('module', [moduleGuard])
        ..detach('module');

      // assert
      expect(actualConfig.guards, orderedEquals(<Object>[baseGuard]));
    });

    test('detach throws StateError when the name was not attached', () {
      // arrange
      final actualConfig = LateInitGuardConfiguration();

      // act & assert
      expect(
        () => actualConfig.detach('missing'),
        throwsStateError,
      );
    });

    test('caches the combined guards between calls', () {
      // arrange
      final actualConfig = LateInitGuardConfiguration(
        guards: [RouteNodeGuardMock()],
      )..attach('m', [RouteNodeGuardMock()]);

      // act
      final actualFirst = actualConfig.guards;
      final actualSecond = actualConfig.guards;

      // assert
      expect(identical(actualFirst, actualSecond), isTrue);
    });

    test('invalidates cache after attach', () {
      // arrange
      final actualConfig = LateInitGuardConfiguration();
      final actualFirst = actualConfig.guards;

      // act
      actualConfig.attach('m', [RouteNodeGuardMock()]);
      final actualSecond = actualConfig.guards;

      // assert
      expect(identical(actualFirst, actualSecond), isFalse);
      expect(actualSecond, hasLength(1));
    });

    test('invalidates cache after detach', () {
      // arrange
      final actualConfig = LateInitGuardConfiguration()
        ..attach('m', [RouteNodeGuardMock()]);
      final actualFirst = actualConfig.guards;

      // act
      actualConfig.detach('m');
      final actualSecond = actualConfig.guards;

      // assert
      expect(identical(actualFirst, actualSecond), isFalse);
      expect(actualSecond, isEmpty);
    });

    test('supports attaching guards under multiple module names', () {
      // arrange/act
      final guardA = RouteNodeGuardMock();
      final guardB = RouteNodeGuardMock();
      final actualConfig = LateInitGuardConfiguration()
        ..attach('a', [guardA])
        ..attach('b', [guardB]);

      // assert: exact set of guards, order-independent.
      expect(actualConfig.guards, unorderedEquals(<Object>[guardA, guardB]));
    });
  });
}
