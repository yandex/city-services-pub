# yx_state: Flutter, scopes, recipes, antipatterns

## Flutter integration

The widgets are provided by `yx_state_flutter`. **There is no `InheritedWidget`** - the manager is passed explicitly through `stateReadable:`.

```dart
// rebuild the UI
StateBuilder<int>(stateReadable: counterManager, builder: (context, state, child) => Text('$state'));
// side effects without a rebuild
StateListener<OrderState>(stateReadable: orderManager, listener: (context, state) {/* ... */}, child: ...);
// builder plus listener
StateConsumer<OrderState>(stateReadable: orderManager, listener: ..., builder: ...);
// rebuild only when the selected slice changes
StateSelector<OrderState, bool>(stateReadable: orderManager, selector: (s) => s.isLoading, builder: ...);
```

Optional filters: `buildWhen` on `StateBuilder`, `listenWhen` on `StateListener`, both on `StateConsumer`. `StateSelector` takes neither - its `selector` is the filter. Pass a heavy static subtree through `child:` - it is not rebuilt.

## Who owns a StateManager

A `StateManager` has a lifetime, so somebody has to own it: create it, hand it out, and call
`close()` when its time is over. A global singleton has no such moment, which is why it is
antipattern 9 below.

Two rules that follow, whatever container you use:

- **`close()` belongs to the owner**, not to the widget that happened to read the state. Wire it into
  whatever your container calls disposal.
- **Hand out `StateReadable<T>`, keep `StateManager<T>`.** Readers only need `state` and `stream`;
  the ability to run `handle` should stay with the code that owns the manager.

```dart
// any container, schematically
final manager = OrderStateManager(repository: repository);   // create
StateReadable<OrderState> get orderState => manager;         // hand out read-only
Future<void> dispose() => manager.close();                   // close
```

With [yx_scope](https://pub.dev/packages/yx_scope) this is a `rawAsyncDep` with a `dispose` callback
and an entry in `initializeQueue`; the `yx-scope-fundamentals` skill shows the exact shape.

## Antipatterns

| # | Antipattern | Why |
|---|---|---|
| 1 | Calling `emit` after `handle` has finished | an assert in debug; in release the write applies outside the queue |
| 2 | Logic outside `handle` | races |
| 3 | `close()` never called on dispose | the stream leaks |
| 4 | Suppressing errors without `addError` | they never reach the observer |
| 5 | Expecting an `InheritedWidget` | yx_state does not work that way - use `stateReadable:` |
| 6 | A StateManager that depends on a StateManager | give the shared step an owner above both of them |
| 7 | Mapping through a getter on the StateManager | keep the state raw and map it outside, with a pure function |
| 8 | A subscription, a timer or another non-value kept inside the state | `emit` writes only when `current != next`, so a value that does not compare meaningfully breaks the filter - keep it as a plain field, see `overview.md` |
| 9 | A StateManager used as a global singleton | give it an owner with a lifetime - a DI container that creates and closes it |
| 10 | Stream mapping inside the StateManager | map over `state` or `stream` outside the manager, with a pure function |

## Recipe: a simple StateManager

```dart
class CounterStateManager extends StateManager<int> {
  CounterStateManager(super.state);
  Future<void> increment() => handle((emit) async => emit(state + 1));
  Future<void> reset() => handle((emit) async => emit(0));
}
```

## Recipe: an async operation with error handling

```dart
class OrderStateManager extends StateManager<OrderState> {
  OrderStateManager({required OrderRepository repository})
      : _repository = repository, super(const OrderState());
  final OrderRepository _repository;

  Future<void> loadOrder(String id) => handle(
    (emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final order = await _repository.getOrder(id);
        emit(state.copyWith(order: order, isLoading: false));
      } on Object catch (e, st) {
        emit(state.copyWith(isLoading: false, error: e));
        addError(e, st, 'loadOrder');  // the identifier is not inherited from handle
      }
    },
    identifier: 'loadOrder',
  );
}
```

On an error restore the state to a safe value and call `addError` so the observer sees it.

**`rethrow` inside a handler does not reach the caller.** `handle` wraps the handler in
`on Object catch` and routes everything to `onError`, so `await manager.loadOrder(id)` completes
normally even when the handler threw. If the caller has to know, put the outcome in the state - the
`error` field above is exactly that - and let it read the state.

## Recipe: wiring into Flutter

```dart
StateBuilder<OrderState>(
  stateReadable: orderManager,
  builder: (context, state, child) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    final error = state.error;
    if (error != null) return _ErrorView(error);
    final order = state.order;
    if (order == null) return const _EmptyView();
    return OrderView(order: order);
  },
);
```
