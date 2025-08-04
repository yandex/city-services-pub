import 'dart:async';

import 'package:meta/meta.dart';

import '../base/interface.dart';

/// Internal implementation of [Emitter] used by [HandleTaskImpl].
///
/// This class manages the state of a single emit operation and provides
/// methods for completion and cancellation.
@internal
class HandleTaskEmitter<State extends Object?> implements Emitter<State> {
  /// The function to emit the state.
  final void Function(State state) _emit;

  /// The completer for the emitter.
  final _completer = Completer<void>();

  /// Whether the emitter has been canceled.
  var _isCanceled = false;

  /// Whether the emitter has been completed.
  var _isCompleted = false;

  /// Whether the emitter is done.
  @override
  bool get isDone => _isCanceled || _isCompleted;

  /// Returns true if the emitter has been canceled.
  bool get isCanceled => _isCanceled;

  /// A future that completes when the emitter is done.
  Future<void> get future => _completer.future;

  /// Creates a new [HandleTaskEmitter] with the provided emit function.
  HandleTaskEmitter(this._emit);

  @override
  void call(State state) {
    assert(
      !_isCompleted,
      'The emitter has already been completed. '
      'This usually happens because of an unawaited future in your handler. '
      'Make sure to await all asynchronous operations and check emit.isDone '
      'before emitting to avoid this issue.',
    );

    // Only emit if the emitter is not canceled
    if (!_isCanceled) {
      _emit(state);
    }
  }

  /// Cancels the emitter.
  ///
  /// After calling this method, the emitter will no longer accept new state
  /// updates and the [future] will complete normally.
  void cancel() {
    if (isDone) {
      return;
    }

    _isCanceled = true;
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  /// Marks the emitter as complete.
  ///
  /// After calling this method, the emitter will no longer accept new state
  /// updates and the [future] will complete normally.
  void complete() {
    if (isDone) {
      return;
    }

    _isCompleted = true;
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  /// Completes the emitter with an error.
  ///
  /// After calling this method, the emitter will no longer accept new state
  /// updates and the [future] will complete with the provided [error] and
  /// [stackTrace].
  void completeError(Object error, StackTrace stackTrace) {
    if (isDone) {
      return;
    }

    _isCompleted = true;
    if (!_completer.isCompleted) {
      _completer.completeError(error, stackTrace);
    }
  }
}
