import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/debug_tools/domain/debug_observer_readable.dart';
import 'package:yx_navigation_flutter/src/debug_tools/domain/log_types.dart';

import '../../helpers/factories.dart';
import '../../helpers/fallbacks.dart';
import '../../helpers/mocks.dart';

/// Creates a [RouteNodeStateManager] that is automatically closed when the enclosing
/// test completes. Must be invoked from within a test body (relies on
/// `addTearDown`).
RouteNodeStateManager _makeStateManager() {
  final sm = RouteNodeStateManager(
      routeNode: makeNode(route: makeRoute(id: 'sm-root')));
  addTearDown(sm.close);
  return sm;
}

void main() {
  setUpAll(registerFallbacks);

  group('DebugObserverReadableImpl', () {
    late DebugObserverReadableImpl observer;
    late RouteNode origin;
    late RouteNode target;

    setUp(() {
      observer = DebugObserverReadableImpl();
      addTearDown(observer.dispose);
      origin = makeNode(route: makeRoute(id: 'origin'));
      target = makeNode(route: makeRoute(id: 'target'));
    });

    test('initially exposes empty log collections', () {
      // assert
      expect(observer.stateManagerLogs, isEmpty);
      expect(observer.guardLogs, isEmpty);
      expect(observer.deeplinkLogs, isEmpty);
    });

    test('onCreate appends OnCreatedLog without notifying listeners', () {
      // arrange
      var notifyCount = 0;
      observer
        ..addListener(() => notifyCount++)
        // act
        ..onCreate(_makeStateManager());

      // assert
      expect(observer.stateManagerLogs, hasLength(1));
      expect(observer.stateManagerLogs.first, isA<OnCreatedLog>());
      expect(notifyCount, equals(0));
    });

    test('onClose appends OnCloseLog and notifies listeners', () {
      // arrange
      var notifyCount = 0;
      observer
        ..addListener(() => notifyCount++)
        // act
        ..onClose(_makeStateManager());

      // assert
      expect(observer.stateManagerLogs, hasLength(1));
      expect(observer.stateManagerLogs.first, isA<OnCloseLog>());
      expect(notifyCount, equals(1));
    });

    test('onMutation appends MutationLog carrying the forwarded mutation', () {
      // arrange
      final mutation = Mutation(
        originalState: origin,
        targetState: target,
      );

      // act
      observer.onMutation(_makeStateManager(), mutation);

      // assert
      expect(observer.stateManagerLogs, hasLength(1));
      final log = observer.stateManagerLogs.first;
      expect(log, isA<MutationLog>());
      log as MutationLog;
      expect(log.mutation, same(mutation));
      expect(log.mutation.originalState, same(origin));
      expect(log.mutation.targetState, same(target));
    });

    test('onError appends ErrorLog carrying the error and stack trace', () {
      // arrange
      final error = Exception('boom');
      final stack = StackTrace.fromString('at main');

      // act
      observer.onError(_makeStateManager(), error, stack);

      // assert
      expect(observer.stateManagerLogs, hasLength(1));
      final log = observer.stateManagerLogs.first;
      expect(log, isA<ErrorLog>());
      log as ErrorLog;
      expect(log.error, same(error));
      expect(log.stackTrace, same(stack));
    });

    test('onStart appends OnStartLog with origin/target set', () {
      // arrange
      var notifyCount = 0;
      observer
        ..addListener(() => notifyCount++)
        // act
        ..onStart(origin, target);

      // assert
      expect(observer.guardLogs, hasLength(1));
      final log = observer.guardLogs.first;
      expect(log, isA<OnStartLog>());
      log as OnStartLog;
      expect(log.origin, same(origin));
      expect(log.target, same(target));
      expect(notifyCount, equals(0));
    });

    test('onGuard appends OnGuardLog carrying the guard, and notifies', () {
      // arrange
      final guard = RouteNodeGuardMock();
      var notifyCount = 0;
      observer
        ..addListener(() => notifyCount++)
        // act
        ..onGuard(origin, target, guard);

      // assert
      expect(observer.guardLogs, hasLength(1));
      final log = observer.guardLogs.first;
      expect(log, isA<OnGuardLog>());
      log as OnGuardLog;
      expect(log.origin, same(origin));
      expect(log.target, same(target));
      expect(log.guard, same(guard));
      expect(notifyCount, equals(1));
    });

    test('onCancel appends OnCancelLog carrying origin/target/guard', () {
      // arrange
      final guard = RouteNodeGuardMock();

      // act
      observer.onCancel(origin, target, guard);

      // assert
      final log = observer.guardLogs.first;
      expect(log, isA<OnCancelLog>());
      log as OnCancelLog;
      expect(log.origin, same(origin));
      expect(log.target, same(target));
      expect(log.guard, same(guard));
    });

    test('onNext appends OnNextLog carrying origin/target and nullable guard',
        () {
      // act
      observer.onNext(origin, target, null);

      // assert
      final log = observer.guardLogs.first;
      expect(log, isA<OnNextLog>());
      log as OnNextLog;
      expect(log.origin, same(origin));
      expect(log.target, same(target));
      expect(log.guard, isNull);
    });

    test(
        'onRedirect appends OnRedirectLog carrying '
        'origin/target/redirect/guard', () {
      // arrange
      final redirect = makeNode(route: makeRoute(id: 'redirect'));

      // act
      observer.onRedirect(origin, target, redirect, null);

      // assert
      final log = observer.guardLogs.first;
      expect(log, isA<OnRedirectLog>());
      log as OnRedirectLog;
      expect(log.origin, same(origin));
      expect(log.target, same(target));
      expect(log.redirect, same(redirect));
      expect(log.guard, isNull);
    });

    test(
        'onGuardError appends OnGuardErrorLog carrying error/stack/guard and '
        'origin/target', () {
      // arrange
      final guard = RouteNodeGuardMock();
      final error = Exception('boom');
      final stack = StackTrace.fromString('trace');

      // act
      observer.onGuardError(origin, target, error, stack, guard);

      // assert
      final log = observer.guardLogs.first;
      expect(log, isA<OnGuardErrorLog>());
      log as OnGuardErrorLog;
      expect(log.origin, same(origin));
      expect(log.target, same(target));
      expect(log.error, same(error));
      expect(log.stackTrace, same(stack));
      expect(log.guard, same(guard));
    });

    test('onGuardSync appends OnGuardSyncLog carrying the reason', () {
      // arrange
      const reason = GuardSyncReason(message: 'boot');

      // act
      observer.onGuardSync(reason);

      // assert
      final log = observer.guardLogs.first;
      expect(log, isA<OnGuardSyncLog>());
      log as OnGuardSyncLog;
      expect(log.reason, same(reason));
    });

    test('onDeeplinkReceived appends DeeplinkReceivedLog carrying uri/state',
        () {
      // arrange
      final uri = Uri.parse('https://example.com/a');

      // act
      observer.onDeeplinkReceived(uri: uri, currentState: origin);

      // assert
      final log = observer.deeplinkLogs.first;
      expect(log, isA<DeeplinkReceivedLog>());
      log as DeeplinkReceivedLog;
      expect(log.uri, equals(uri));
      expect(log.currentState, same(origin));
    });

    test(
        'onDeeplinkNavigate appends DeeplinkNavigateLog carrying '
        'uri/currentState/targetState', () {
      // arrange
      final uri = Uri.parse('https://example.com/b');

      // act
      observer.onDeeplinkNavigate(
        uri: uri,
        currentState: origin,
        targetState: target,
      );

      // assert
      final log = observer.deeplinkLogs.first;
      expect(log, isA<DeeplinkNavigateLog>());
      log as DeeplinkNavigateLog;
      expect(log.uri, equals(uri));
      expect(log.currentState, same(origin));
      expect(log.targetState, same(target));
    });

    test('onDeeplinkHandled appends DeeplinkHandledLog carrying uri/state', () {
      // arrange
      final uri = Uri.parse('https://example.com/c');

      // act
      observer.onDeeplinkHandled(uri: uri, currentState: origin);

      // assert
      final log = observer.deeplinkLogs.first;
      expect(log, isA<DeeplinkHandledLog>());
      log as DeeplinkHandledLog;
      expect(log.uri, equals(uri));
      expect(log.currentState, same(origin));
    });

    test('onDeeplinkSkipped appends DeeplinkSkippedLog carrying uri/state', () {
      // arrange
      final uri = Uri.parse('https://example.com/d');

      // act
      observer.onDeeplinkSkipped(uri: uri, currentState: origin);

      // assert
      final log = observer.deeplinkLogs.first;
      expect(log, isA<DeeplinkSkippedLog>());
      log as DeeplinkSkippedLog;
      expect(log.uri, equals(uri));
      expect(log.currentState, same(origin));
    });

    test(
        'onDeeplinkError appends DeeplinkErrorLog carrying '
        'uri/state/error/stack', () {
      // arrange
      final uri = Uri.parse('https://example.com/e');
      final error = Exception('boom');
      final stack = StackTrace.fromString('trace');

      // act
      observer.onDeeplinkError(
        uri: uri,
        currentState: origin,
        error: error,
        stackTrace: stack,
      );

      // assert
      final log = observer.deeplinkLogs.first;
      expect(log, isA<DeeplinkErrorLog>());
      log as DeeplinkErrorLog;
      expect(log.uri, equals(uri));
      expect(log.currentState, same(origin));
      expect(log.error, same(error));
      expect(log.stackTrace, same(stack));
    });

    test('circular buffer drops oldest entries beyond capacity', () {
      // arrange
      for (var i = 0; i < 1005; i++) {
        observer.onCreate(_makeStateManager());
      }

      // assert
      expect(observer.stateManagerLogs, hasLength(1000));
    });

    group('notification asymmetry contract', () {
      // `onCreate` and `onStart` are intentionally silent — they mark the
      // beginning of a transition and would cause noisy rebuilds if they
      // notified. Every other hook triggers notifyListeners() exactly once.

      late int count;

      setUp(() {
        count = 0;
        observer.addListener(() => count++);
      });

      test('onCreate does NOT notify listeners', () {
        observer.onCreate(_makeStateManager());
        expect(count, equals(0));
      });

      test('onStart does NOT notify listeners', () {
        observer.onStart(origin, target);
        expect(count, equals(0));
      });

      test('onMutation notifies listeners exactly once', () {
        observer.onMutation(
          _makeStateManager(),
          Mutation(originalState: origin, targetState: target),
        );
        expect(count, equals(1));
      });

      test('onError notifies listeners exactly once', () {
        observer.onError(
          _makeStateManager(),
          Exception('x'),
          StackTrace.fromString('s'),
        );
        expect(count, equals(1));
      });

      test('onClose notifies listeners exactly once', () {
        observer.onClose(_makeStateManager());
        expect(count, equals(1));
      });

      test('onGuard notifies listeners exactly once', () {
        observer.onGuard(origin, target, RouteNodeGuardMock());
        expect(count, equals(1));
      });

      test('onNext notifies listeners exactly once', () {
        observer.onNext(origin, target, null);
        expect(count, equals(1));
      });

      test('onCancel notifies listeners exactly once', () {
        observer.onCancel(origin, target, RouteNodeGuardMock());
        expect(count, equals(1));
      });

      test('onRedirect notifies listeners exactly once', () {
        final redirect = makeNode(route: makeRoute(id: 'redirect'));
        observer.onRedirect(origin, target, redirect, null);
        expect(count, equals(1));
      });

      test('onGuardError notifies listeners exactly once', () {
        observer.onGuardError(
          origin,
          target,
          Exception('x'),
          StackTrace.fromString('s'),
          RouteNodeGuardMock(),
        );
        expect(count, equals(1));
      });

      test('onGuardSync notifies listeners exactly once', () {
        observer.onGuardSync(const GuardSyncReason(message: 'boot'));
        expect(count, equals(1));
      });

      test('onDeeplinkReceived notifies listeners exactly once', () {
        observer.onDeeplinkReceived(
          uri: Uri.parse('https://example.com/a'),
          currentState: origin,
        );
        expect(count, equals(1));
      });

      test('onDeeplinkNavigate notifies listeners exactly once', () {
        observer.onDeeplinkNavigate(
          uri: Uri.parse('https://example.com/b'),
          currentState: origin,
          targetState: target,
        );
        expect(count, equals(1));
      });

      test('onDeeplinkHandled notifies listeners exactly once', () {
        observer.onDeeplinkHandled(
          uri: Uri.parse('https://example.com/c'),
          currentState: origin,
        );
        expect(count, equals(1));
      });

      test('onDeeplinkSkipped notifies listeners exactly once', () {
        observer.onDeeplinkSkipped(
          uri: Uri.parse('https://example.com/d'),
          currentState: origin,
        );
        expect(count, equals(1));
      });

      test('onDeeplinkError notifies listeners exactly once', () {
        observer.onDeeplinkError(
          uri: Uri.parse('https://example.com/e'),
          currentState: origin,
          error: Exception('x'),
          stackTrace: StackTrace.fromString('s'),
        );
        expect(count, equals(1));
      });
    });
  });
}
