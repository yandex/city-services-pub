import 'dart:async';

import 'package:meta/meta.dart';

import '../base/interface.dart';
import 'handle_task.dart';

/// A function handler implementation that uses streams to process state updates.
///
/// This class provides the core implementation for different function handling
/// strategies through the use of transformers.
class StreamFunctionHandler<State extends Object?>
    implements FunctionHandler<State> {
  /// The transformer that determines how tasks are processed.
  final HandleTaskTransformer<State> _handleTransformer;

  /// The controller for the task stream.
  final _taskController = StreamController<HandleTask<State>>.broadcast();

  /// The list of tasks.
  final _tasks = <HandleTask<State>>[];

  /// The subscription for the task stream.
  late final StreamSubscription<HandleTask<State>> _taskSub;

  /// Whether the handler is closing.
  bool _isClosing = false;

  /// Whether the handler is closed.
  @override
  bool get isClosed => _taskController.isClosed;

  /// Creates a new [StreamFunctionHandler] with the provided [handleTransformer].
  ///
  /// The [handleTransformer] determines how tasks are processed (sequentially,
  /// concurrently, etc.).
  StreamFunctionHandler({
    required HandleTaskTransformer<State> handleTransformer,
  }) : _handleTransformer = handleTransformer {
    _taskSub = _onTask();
  }

  @override
  Future<void> call(
    EmitterHandler<State> handler,
    Object? identifier, {
    required Emittable<State> onEmit,
    required void Function(Object error, StackTrace stackTrace) onError,
    required void Function() onStart,
    required void Function() onDone,
  }) async {
    if (isClosed) {
      throw StateError('Cannot handle new handler after calling close');
    }

    final task = HandleTask<State>(
      handler,
      identifier,
      onEmit,
      onStart,
      onDone,
    );

    _taskController.add(task);
    try {
      await task.future;
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  /// Closes the function handler and cancels all active tasks.
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
      // Close the task controller
      await _taskController.close();

      // Cancel all active tasks first
      for (final task in List<HandleTask<State>>.from(_tasks)) {
        task.cancel();
      }

      // Wait for all tasks to complete
      //
      // We ignore the error, because it is expected that
      // it might throw an error.
      await Future.wait<void>(_tasks.map((e) => e.future)).onError(
        (_, __) => const [],
      );

      // Cancel the subscription
      await _taskSub.cancel();
    } finally {
      _isClosing = false;
    }
  }

  /// Sets up the task processing pipeline using the provided transformer.
  StreamSubscription<HandleTask<State>> _onTask() {
    final subscription = _handleTransformer(
      _taskController.stream,
      (task) {
        final controller = StreamController<HandleTask<State>>.broadcast(
          sync: true,
          onCancel: task.cancel,
        );

        // Add the task to the list of tasks
        void onBegin() => _tasks.add(task);

        // Remove the task from the list of tasks
        void onComplete() {
          _tasks.remove(task);
          if (!controller.isClosed) {
            controller.close();
          }
        }

        task.handle(onBegin, onComplete);
        return controller.stream;
      },
    ).listen(null);
    return subscription;
  }
}
