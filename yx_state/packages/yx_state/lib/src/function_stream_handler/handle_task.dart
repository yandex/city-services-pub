import 'package:meta/meta.dart';

import '../base/interface.dart';
import 'handle_task_emitter.dart';

/// Signature for a function which converts an incoming task
/// into an outbound stream of tasks.
///
/// Used when defining custom [HandleTaskTransformer]s.
typedef HandleTaskMapper<State extends Object?> = Stream<HandleTask<State>>
    Function(HandleTask<State> task);

/// Used to change how tasks are processed.
///
/// The transformer defines the concurrency behavior of the tasks.
typedef HandleTaskTransformer<State extends Object?> = Stream<HandleTask<State>>
    Function(Stream<HandleTask<State>> tasks, HandleTaskMapper<State> mapper);

/// A task that can be handled by a function handler.
class HandleTask<State extends Object?> {
  /// The identifier for the task.
  final Object? identifier;

  /// The handler for the task.
  final EmitterHandler<State> _handler;

  /// The callback to call when the task starts.
  final void Function() _onStart;

  /// The callback to call when the task is done.
  final void Function() _onDone;

  /// The emitter for the task.
  final HandleTaskEmitter<State> _emitter;

  /// Returns true if the task is done.
  bool get isDone => _emitter.isDone;

  /// Returns true if the task is canceled.
  bool get isCanceled => _emitter.isCanceled;

  /// A future that completes when the task is done.
  Future<void> get future => _emitter.future;

  /// Creates a new [HandleTask] with the provided handler and callbacks.
  HandleTask(
    this._handler,
    this.identifier,
    Emittable<State> _emittable,
    this._onStart,
    this._onDone, {
    @visibleForTesting HandleTaskEmitter<State>? emitter,
  }) : _emitter = emitter ?? HandleTaskEmitter(_emittable);

  /// Cancels the task.
  ///
  /// This will prevent the task from emitting any more state updates
  /// and will mark the task as canceled.
  void cancel() => _emitter.cancel();

  /// Executes the handler function and manages its lifecycle.
  ///
  /// This method:
  /// 1. Calls [onBegin] to signal the start of the task
  /// 2. Executes the handler function
  /// 3. Handles any errors that occur during execution
  /// 4. Marks the task as complete
  /// 5. Calls [onComplete] to signal the end of the task
  Future<void> handle(
    void Function() onBegin,
    void Function() onComplete,
  ) async {
    try {
      _onBegin(onBegin);
      await _handler(_emitter);
    } on Object catch (error, stackTrace) {
      // Only complete the emitter if it's not already done
      if (!_emitter.isDone) {
        _emitter.completeError(error, stackTrace);
      }
    } finally {
      // Only complete the emitter if it's not already done
      if (!_emitter.isDone) {
        _emitter.complete();
      }
      _onComplete(onComplete);
    }
  }

  /// Calls the [onBegin] callback and then the [onStart] callback.
  void _onBegin(void Function() onBegin) {
    onBegin();
    _onStart();
  }

  /// Calls the [onComplete] callback and then the [onDone] callback.
  void _onComplete(void Function() onComplete) {
    onComplete();
    _onDone();
  }
}
