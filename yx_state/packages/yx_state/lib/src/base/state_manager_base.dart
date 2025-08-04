import 'dart:async';

import 'package:meta/meta.dart';
import 'package:yx_state/src/state_manager_overrides.dart';

import 'interface.dart';
part '../test_util/state_manager_base_test_util.dart';

/// Base implementation of a state manager.
abstract class StateManagerBase<State extends Object?>
    implements
        StateReadable<State>,
        StateManagerHandler<State>,
        StateManagerListener<State>,
        Closable {
  /// Creates a new [StateManagerBase] with the provided initial [state]
  /// and function [handler].
  StateManagerBase(
    State state, {
    required FunctionHandler<State> handler,
  })  : _state = state,
        _functionHandler = handler {
    onCreate();
  }

  final FunctionHandler<State> _functionHandler;
  late final _controller = StreamController<State>.broadcast();
  State _state;
  bool _isClosing = false;

  @nonVirtual
  @override
  bool get isClosed => _controller.isClosed;

  @override
  State get state => _state;

  @override
  Stream<State> get stream => _controller.stream;

  @nonVirtual
  @protected
  @override
  Future<void> handle(
    EmitterHandler<State> handler, {
    Object? identifier,
  }) async {
    try {
      if (isClosed) {
        throw StateError(
          'Cannot handle handler after the state manager '
          'has been closed',
        );
      }
      await _functionHandler.call(
        handler,
        identifier,
        onEmit: (state) => _emit(state, identifier),
        onError: (error, stackTrace) => onError(error, stackTrace, identifier),
        onStart: () => onStart(identifier),
        onDone: () => onDone(identifier),
      );
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace, identifier);
    }
  }

  /// Adds an error to the state manager.
  ///
  /// This method will call [onError] with the provided [error], [stackTrace],
  /// and [identifier]. Use this method to report errors that occur outside of
  /// the normal state update flow.
  @protected
  @mustCallSuper
  void addError(Object error, [StackTrace? stackTrace, Object? identifier]) {
    onError(error, stackTrace ?? StackTrace.current, identifier);
  }

  /// Closes the state manager and releases all resources.
  ///
  /// After calling this method, the state manager will no longer accept
  /// new state updates and all streams will be closed.
  ///
  /// This method is idempotent - calling it multiple times has the same effect
  /// as calling it once.
  @mustCallSuper
  @override
  Future<void> close() async {
    if (isClosed || _isClosing) {
      return;
    }

    _isClosing = true;

    try {
      await _functionHandler.close();
      onClose();
      await _controller.close();
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace, null);
    } finally {
      _isClosing = false;
    }
  }

  /// Determines whether a state update should be emitted.
  ///
  /// By default, this method returns true if the current state is not equal
  /// to the next state. Override this method to provide custom equality
  /// checking logic for complex state objects.
  @protected
  bool shouldEmit(State current, State next) =>
      StateManagerOverrides.defaultShouldEmit(current, next);

  /// Emits a new state value.
  ///
  /// This method:
  /// 1. Checks if the state manager is closed
  /// 2. Determines if the new state should be emitted using [shouldEmit]
  /// 3. Calls [onChange] with the current and next state
  /// 4. Updates the internal state
  /// 5. Adds the new state to the stream
  ///
  /// If an error occurs during this process, it will be reported via [onError].
  void _emit(State state, Object? identifier) {
    try {
      if (isClosed) {
        throw StateError('Cannot emit new states after calling close');
      }

      final prev = _state;
      if (!shouldEmit(prev, state)) {
        return;
      }

      onChange(_state, state, identifier);
      _state = state;
      _controller.add(state);
    } on Object catch (error, sk) {
      onError(error, sk, identifier);
      rethrow;
    }
  }
}
