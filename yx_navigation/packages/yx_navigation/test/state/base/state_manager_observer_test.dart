import 'dart:async';

import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/state/base/base_state_manager.dart';
import 'package:yx_navigation/src/state/base/mutation.dart';
import 'package:yx_navigation/src/state/base/state_manager_observer.dart';
import 'package:yx_navigation/src/state/state_manager.dart';

import '../../helpers/async.dart';
import '../../helpers/factories.dart';
import '../../helpers/fallbacks.dart';

/// Records every hook invocation so we can assert that a real
/// `RouteNodeStateManager` lifecycle actually dispatches to the observer.
class _RecordingObserver extends StateManagerObserver {
  final List<String> calls = [];

  @override
  void onCreate(BaseStateManager stateManager) {
    super.onCreate(stateManager);
    calls.add('onCreate');
  }

  @override
  void onMutation(
    BaseStateManager stateManager,
    Mutation mutation,
  ) {
    super.onMutation(stateManager, mutation);
    calls.add('onMutation');
  }

  @override
  void onError(
    BaseStateManager stateManager,
    Object error,
    StackTrace stackTrace,
  ) {
    super.onError(stateManager, error, stackTrace);
    calls.add('onError');
  }

  @override
  void onClose(BaseStateManager stateManager) {
    super.onClose(stateManager);
    calls.add('onClose');
  }
}

void main() {
  setUpAll(registerFallbacks);

  group('StateManagerObserver', () {
    testAsync(
      'real RouteNodeStateManager lifecycle (create -> mutate -> close) dispatches '
      'onCreate, onMutation and onClose in order to the observer',
      (fa) {
        // arrange
        final actualObserver = _RecordingObserver();
        final actualStateManager = RouteNodeStateManager(
          routeNode: makeNode(route: makeRoute(id: 'root')),
          observer: actualObserver,
        );

        // act: push (to trigger onMutation via emit) then close.
        unawaited(
          (actualStateManager..push(const YxRoute(id: 'pushed'))).close(),
        );
        fa.flushMicrotasks();

        // assert: onCreate fires from the constructor, onMutation fires from
        // the push (which triggers emit), and onClose fires from close.
        expect(
          actualObserver.calls,
          orderedEquals(<String>['onCreate', 'onMutation', 'onClose']),
        );
      },
    );
  });
}
