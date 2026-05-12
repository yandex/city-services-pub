import 'dart:async';

import 'package:meta/meta.dart';

import '../../base/route_navigator.dart';
import '../../base/route_node.dart';
import 'mutation.dart';
import 'state_manager_observer.dart';

/// {@template base_state_manager}
/// Base class for navigation state managers.
///
/// [BaseStateManager] owns the current [RouteNode], exposes it through
/// [state] and [stream], and wires in a [StateManagerObserver] that receives
/// lifecycle callbacks ([StateManagerObserver.onCreate],
/// [StateManagerObserver.onMutation], [StateManagerObserver.onError] and
/// [StateManagerObserver.onClose]).
///
/// Subclasses implement the mutation policy (for example, running guards)
/// and call [emit] to publish a new state.
/// {@endtemplate}
abstract base class BaseStateManager extends BaseRouteNavigator {
  final StateManagerObserver? _observer;
  late final _controller = StreamController<RouteNode>.broadcast();
  RouteNode _state;

  @nonVirtual
  @override
  RouteNode get state => _state;

  @nonVirtual
  @override
  Stream<RouteNode> get stream => _controller.stream;

  @nonVirtual
  @override
  bool get isClosed => _controller.isClosed;

  /// {@macro base_state_manager}
  ///
  /// [state] is the initial tree. [observer] is notified of lifecycle events.
  BaseStateManager(
    RouteNode state, {
    StateManagerObserver? observer,
  })  : _state = state,
        _observer = observer {
    _observer?.onCreate(this);
  }

  /// Publishes [state] as the new current state.
  ///
  /// Called by subclasses after any mutation policy (such as guards) has
  /// accepted the transition. Throws if the manager has already been closed.
  @protected
  @visibleForTesting
  void emit(RouteNode state) {
    try {
      if (isClosed) {
        throw StateError('Cannot emit new states after calling close');
      }

      if (state == _state) {
        return;
      }

      onMutation(Mutation(originalState: this.state, targetState: state));

      _state = state;
      _controller.add(_state);
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
  }

  @protected
  @mustCallSuper
  void onMutation(Mutation mutation) {
    // ignore: invalid_use_of_protected_member
    _observer?.onMutation(this, mutation);
  }

  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    _observer?.onError(this, error, stackTrace);
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    // ignore: invalid_use_of_protected_member
    _observer?.onClose(this);
    await _controller.close();
  }
}
