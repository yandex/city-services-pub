import 'dart:async';

import 'package:stream_transform/stream_transform.dart';
import 'package:yx_state/yx_state.dart';

/// {@template task_transformers}
/// A collection of transformers for controlling how tasks are processed.
///
/// These transformers implement different concurrency strategies to control how
/// state update tasks are processed. Each strategy provides different behavior
/// for handling multiple state updates that occur close together.
///
/// Available strategies:
///
/// - [sequential]: Process tasks one at a time in order (FIFO queue)
///   * Tasks are processed in the order they are received
///   * New tasks are queued until current task completes
///   * Best for when order of operations matters
///
/// - [concurrent]: Process all tasks concurrently without restrictions
///   * All tasks run at the same time without waiting
///   * Can lead to race conditions if not used carefully
///   * Best for independent operations that don't affect each other
///
/// - [droppable]: Process one task at a time, ignoring new tasks while busy
///   * If a task is running, new tasks are ignored (dropped)
///   * Prevents task queue buildup during rapid events
///   * Best for preventing spamming of expensive operations
///
/// - [restartable]: Process one task at a time, cancelling current task when new arrives
///   * If a task is running, it gets cancelled when a new task arrives
///   * Only the latest task is processed to completion
///   * Best for search-as-you-type and other scenarios where only latest input matters
/// {@endtemplate}
abstract class HandleTaskTransformers {
  static HandleTaskTransformer<State> sequential<State extends Object?>() {
    return (tasks, mapper) => tasks.asyncExpand<HandleTask<State>>(mapper);
  }

  static HandleTaskTransformer<State> concurrent<State extends Object?>() {
    return (tasks, mapper) =>
        tasks.concurrentAsyncExpand<HandleTask<State>>(mapper);
  }

  static HandleTaskTransformer<State> droppable<State extends Object?>() {
    return (tasks, mapper) => tasks
        .transform<HandleTask<State>>(_ExhaustMapStreamTransformer(mapper));
  }

  static HandleTaskTransformer<State> restartable<State extends Object?>() {
    return (tasks, mapper) => tasks.switchMap<HandleTask<State>>(mapper);
  }
}

class _ExhaustMapStreamTransformer<State extends Object?>
    extends StreamTransformerBase<HandleTask<State>, HandleTask<State>> {
  _ExhaustMapStreamTransformer(this.mapper);

  final HandleTaskMapper<State> mapper;

  @override
  Stream<HandleTask<State>> bind(Stream<HandleTask<State>> stream) {
    late StreamSubscription<HandleTask<State>> subscription;
    StreamSubscription<HandleTask<State>>? mappedSubscription;

    final controller = StreamController<HandleTask<State>>(
      onCancel: () async {
        await mappedSubscription?.cancel();
        return subscription.cancel();
      },
      sync: true,
    );

    subscription = stream.listen(
      (task) {
        if (mappedSubscription != null) {
          task.cancel();
          return;
        }
        mappedSubscription = mapper(task).listen(
          controller.add,
          onError: controller.addError,
          onDone: () => mappedSubscription = null,
        );
      },
      onError: controller.addError,
      onDone: () => mappedSubscription ?? controller.close(),
    );

    return controller.stream;
  }
}
