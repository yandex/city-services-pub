import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// internal type, not exported
import 'package:yx_navigation_flutter/src/compatibility/source_route_completer.dart';

import '../helpers/fallbacks.dart';

/// Stub that mimics subclasses (e.g. CupertinoPageRoute with hasLocalHistory,
/// or ModalRoute with hasPendingPopScope) which override [didPop] to return
/// `false` without calling [didComplete]. SourceRouteCompleter must bypass
/// this and invoke [didComplete] directly.
class _DidPopFalseRoute<T> extends Route<T> {
  _DidPopFalseRoute();

  int didPopCalls = 0;
  int didCompleteCalls = 0;
  T? lastDidCompleteResult;

  // Intentionally does NOT call super.didPop: the whole point of the stub is
  // to model subclasses (CupertinoPageRoute.hasLocalHistory, pending
  // PopScope) that return `false` early and never call didComplete.
  @override
  // ignore: must_call_super
  bool didPop(T? result) {
    didPopCalls++;
    return false;
  }

  @override
  void didComplete(T? result) {
    didCompleteCalls++;
    lastDidCompleteResult = result;
    super.didComplete(result);
  }
}

void main() {
  setUpAll(registerFallbacks);

  group('SourceRouteCompleter', () {
    testWidgets('complete delivers result to source route popped future',
        (tester) async {
      // arrange
      final actualSourceRoute = MaterialPageRoute<String>(
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      SourceRouteCompleter<String>(actualSourceRoute).complete('ok');
      final actualResult = await actualSourceRoute.popped;

      // assert
      expect(actualResult, equals('ok'));
    });

    test(
      'complete invokes didComplete even when the source route overrides '
      'didPop to return false (CupertinoPageRoute.hasLocalHistory case)',
      () async {
        // arrange: a route whose didPop would NOT call didComplete.
        final route = _DidPopFalseRoute<String>();

        // act
        SourceRouteCompleter<String>(route).complete('local-history');

        // assert: didPop was bypassed; didComplete fired with the result.
        expect(route.didPopCalls, equals(0));
        expect(route.didCompleteCalls, equals(1));
        expect(route.lastDidCompleteResult, equals('local-history'));
        // popped future resolves because didComplete was called.
        expect(await route.popped, equals('local-history'));
      },
    );

    test(
      'complete invokes didComplete even when route has a pending PopScope '
      '(ModalRoute.hasPendingPopScope case)',
      () async {
        // arrange: same stub models the PopScope path — didPop returns false
        // and never calls didComplete on its own.
        final route = _DidPopFalseRoute<int>();

        // act
        SourceRouteCompleter<int>(route).complete(42);

        // assert
        expect(route.didCompleteCalls, equals(1));
        expect(await route.popped, equals(42));
      },
    );
  });
}
