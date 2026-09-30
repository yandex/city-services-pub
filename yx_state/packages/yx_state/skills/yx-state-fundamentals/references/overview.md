# yx_state: state management

Reactive business state through a `StateManager`. The entry point: the concepts, the kinds of state, the strategies. The handle and emit rules and `close()` are in [handle.md](handle.md); the Observer and the overrides are in [observer.md](observer.md). Flutter, scopes and recipes are in [flutter_recipes.md](flutter_recipes.md).

## Concepts

- **`StateManager<T>`** - manages one business state `T`. The `state` getter returns the current value and `stream` emits changes. Calling `close()` is mandatory, and it is the job of whoever created the manager - typically the DI container that owns it.
- **`handle((emit) async {...})`** - the wrapper around business logic; it runs the operation queue according to the chosen strategy. It returns a `Future<void>`, so it can be awaited.
- **`emit(next)`** - available inside `handle`, updates the state. By default it takes effect only when `current != next`. `emit.isDone` is true once this handler is done accepting writes - that is, after it was cancelled or after it completed.
- **`StateReadable<T>`** - the read-only interface. Widgets read through `stateReadable:`.
- **`identifier`** - an optional label for an operation, used by `StateManagerObserver` for tracking and analytics.
- **`addError(error, st, [identifier])`** - reports an error to the Observer manually, from a catch block inside `handle`. The identifier is a separate third argument and is **not** taken from the enclosing `handle`: without it the Observer sees `identifier == null`.

## Kinds of state

The package puts no constraint on `T` - a `StateManager<T>` carries whatever you give it. The three
kinds below are named so that you can tell them apart; where each of them should live is an
architecture question and this skill does not answer it.

- **Business state** - a business context such as authorization, an order, a feature. This is what a
  `StateManager` is meant for.
- **Service state** - the technical fields of a class: a `StreamSubscription`, a `Completer`, a
  timer. Keep these as plain fields, and here the package does have a say: `emit` writes only when
  `current != next`, so the state has to be something that compares meaningfully, which a
  subscription or a timer is not. `isClosed` already tells you whether the manager is closed.
- **Ephemeral state** - specific to one piece of UI, such as a scroll position, hover or highlight.
  It compares fine, so nothing in the package stops you putting it in a `StateManager`; whether you
  should is the architecture question above.

One `StateManager` changes one state. Logic that has to change two of them at once needs something
above them that owns both - what that something is called is up to your architecture.

## Operation strategies

The default behaviour is sequential and needs no extra package: `yx_state` builds it in. The named strategies below come from `package:yx_state_transformers`; add it only when you need one other than the default.

| Strategy | Behaviour | When to use |
|---|---|---|
| `sequential()` | a queue, one at a time | **the default** |
| `concurrent()` | in parallel | independent fire-and-forget work |
| `droppable()` | ignores new calls while one is running | protection against a double tap |
| `restartable()` | cancels the running one when a new call arrives | a search or filter request that a newer one makes obsolete |

```dart
class SearchStateManager extends StateManager<SearchState> {
  SearchStateManager(super.state, this._api) : super(handler: restartable());

  final SearchApi _api;

  Future<void> search(String query) => handle((emit) async {
    emit(state.copyWith(isLoading: true));
    final results = await _api.search(query);
    if (emit.isDone) return;  // return early when cancelled
    emit(state.copyWith(isLoading: false, results: results));
  });
}
```

`restartable` is the one that cancels: the previous handler keeps running, but its `emit` calls are ignored from that moment. `droppable` cancels nothing - it simply does not start the new call while one is in flight. To stop heavy work inside a cancelled handler, check `emit.isDone`.

**There is no debounce here.** `restartable` starts the new handler at once and only stops the old one from writing; nothing waits for a quiet period. To coalesce a burst of calls, put the pause before `handle` - in the view model or the widget - and keep the strategy for what happens once the call is made.
