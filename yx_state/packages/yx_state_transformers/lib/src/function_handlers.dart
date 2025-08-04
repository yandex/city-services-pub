import 'package:yx_state/yx_state.dart';

import 'handle_task_transformers.dart';

/// Process tasks one at a time by maintaining a queue of added tasks
/// and processing the tasks sequentially.
///
/// This is the default and safest handler to use in most cases.
FunctionHandler<State> sequential<State extends Object?>() =>
    StreamFunctionHandler<State>(
        handleTransformer: HandleTaskTransformers.sequential());

/// Process tasks concurrently without any restrictions.
///
/// Use with caution as concurrent state updates may lead to race conditions.
FunctionHandler<State> concurrent<State extends Object?>() =>
    StreamFunctionHandler<State>(
        handleTransformer: HandleTaskTransformers.concurrent());

/// Process only one task and ignore (drop) any new tasks
/// until the current task is done.
///
/// Useful for preventing spamming of state updates during ongoing operations.
FunctionHandler<State> droppable<State extends Object?>() =>
    StreamFunctionHandler<State>(
        handleTransformer: HandleTaskTransformers.droppable());

/// Process only one task by cancelling any pending tasks and
/// processing the new task immediately.
///
/// Useful for operations where only the latest request matters.
FunctionHandler<State> restartable<State extends Object?>() =>
    StreamFunctionHandler<State>(
        handleTransformer: HandleTaskTransformers.restartable());
