# yx_state: the handle and emit rules, close()

## The handle/emit rules

**Allowed:**
- All business logic **inside** `handle` only - otherwise the queue does not work.
- Several `emit` calls in a row inside one `handle`, for a staged change.
- try/catch plus `addError(e, st)`.

```dart
Future<void> complexIncrement() => handle((emit) async {
  emit(state + 1);
  await Future.delayed(const Duration(milliseconds: 100));
  emit(state + 1);
});
```

**Forbidden - calling `emit` after `handle` has finished** (an async callback that is never awaited). In debug this throws an `AssertionError`. In release the assert is stripped and the write goes through: the emitter checks whether it was *cancelled*, not whether it finished, so the state changes outside its own operation and outside the queue. Cancellation happens where the strategy cancels the task - `restartable` on a new call, and `close()` under every strategy except the default `sequential` (see below) - so while a manager is alive and running on `sequential` or `concurrent`, a late emit is always applied. The failure is therefore invisible in tests and real in production:

```dart
// WRONG
Future<void> bad() => handle((emit) async {
  Future.delayed(d, () => emit(state + 1));  // runs AFTER handle is done
});
```

**Forbidden - logic outside `handle`** (the queue is bypassed, race conditions appear):

```dart
// WRONG - part of the logic sits outside
Future<void> bad() async {
  final v = state + 1;
  await Future.delayed(d);
  return handle((emit) async => emit(v));
}
// RIGHT - everything is inside
Future<void> ok() => handle((emit) async {
  final v = state + 1;
  await Future.delayed(d);
  emit(v);
});
```

## What close() does to a handler that is still running

It depends on the strategy, and the default is the odd one out. `close()` closes the task stream
first and cancels the tasks only afterwards, so what matters is whether closing the stream waits for
the handler in flight:

| Strategy | A handler still running when `close()` is called | A handler that never finishes |
|---|---|---|
| `sequential` (the default) | `close()` **waits** for it, and an `emit` it makes afterwards is still applied | holds `close()` forever |
| `concurrent()`, `droppable()`, `restartable()` | the task is cancelled at once, `close()` returns immediately, and a later `emit` is dropped | does not hold `close()` |

Measured: with the default, a handler that sleeps 700 ms holds `close()` for 650 ms and its `emit`
after the sleep lands in the state; with the other three, `close()` returns in about 1 ms and that
`emit` never applies. The reason is `asyncExpand`, which the default is built on: it passes `done`
downstream only after the inner stream is finished. The other three transformers do not wait.

**Cancelling the task is not cancelling the work.** Cancellation is cooperative everywhere: the
handler body keeps running until it checks `emit.isDone`, only its writes stop being applied. A
network request or a long read carries on after the manager is gone, whatever the strategy. So the
escape hatch below is not optional for anything long - cancel the operation yourself before
`super.close()`.

```dart
class SomeStateManager extends StateManager<SomeState> {
  SomeStateManager(super.state, this._api);
  final SomeApi _api;

  Future<void> readSomeData() => handle((emit) async {
    final data = await _api.getData();  // this one can hang
    emit(state.copyWith(data: data));
  });

  @override
  Future<void> close() async {
    await _api.cancelGetData();  // cancel first
    return super.close();
  }
}
```
