# ViewModel recipes, a complex screen, antipatterns

Every example implements the two-member `StateReadable<T>` from [overview.md](overview.md). The only imports used are `dart:async` and `package:yx_state/yx_state.dart`.

## Antipatterns

| # | Antipattern | Why |
|---|---|---|
| 1 | Flutter imports in a ViewModel | a ViewModel is pure Dart; the widget owns the `BuildContext`, not the ViewModel |
| 2 | Registering a ViewModel as a `dep` | its lifetime is the screen's, shorter than any scope; the widget creates and disposes it |
| 3 | A ViewModel that depends on another ViewModel | shared logic belongs in domain |
| 4 | Business state kept in the ViewModel | it belongs to a `StateManager`; the ViewModel holds ephemeral state only |
| 5 | Mapping the domain inside the StateManager | keep the state raw, map it in the ViewModel with a pure function |
| 6 | Two build paths - `state` computes one thing, the stream emits another | build the view object in one method and call it from both |
| 7 | `StreamController<T>()` without `.broadcast()` | the second `StateBuilder` on the screen throws `Bad state: Stream has already been listened to` |
| 8 | Replaying the current value into the stream on subscription | `StateBuilder` already took it from `state`; the replay is one extra rebuild |
| 9 | No `dispose()`, or subscriptions that are never cancelled | the subscription outlives the screen and keeps rebuilding a dead widget |
| 10 | Emitting after `dispose()` | `Bad state: Cannot add event after closing`; cancel the subscriptions before closing the controller |
| 11 | Heavy logic in the `state` getter | it runs on every rebuild and on every emit - keep it pure and cheap |
| 12 | Accessing Data from a ViewModel | go through domain only: an Interactor or a `StateReadable` |

## Recipe: proxying a single StateManager

The common case, and the cheapest one: the ViewModel owns nothing, so it needs no `dispose()`. `Stream.map` over a broadcast stream stays broadcast, so several widgets can read it.

```dart
class OrderViewModel implements StateReadable<OrderViewObject> {
  OrderViewModel({
    required OrderInteractor interactor,
    required StateReadable<OrderState> orderState,
  })  : _interactor = interactor,
        _orderState = orderState;

  final OrderInteractor _interactor;
  final StateReadable<OrderState> _orderState;

  @override
  OrderViewObject get state => _map(_orderState.state);

  @override
  Stream<OrderViewObject> get stream => _orderState.stream.map(_map);

  void onRefreshTap() => _interactor.reloadOrder();  // a command goes to the Interactor

  static OrderViewObject _map(OrderState state) => OrderViewObject(
        title: state.order?.title ?? '',
        isLoading: state.isLoading,
        showError: state.error != null,
      );
}
```

## Recipe: ephemeral state of its own

A value that exists only in the UI - a step counter, an expanded flag, the text being typed. The field is the source of truth, the controller only announces changes.

```dart
class StepperViewModel implements StateReadable<int> {
  final _changes = StreamController<int>.broadcast();
  int _value = 0;

  @override
  int get state => _value;

  @override
  Stream<int> get stream => _changes.stream;

  void onNextTap() => _emit(_value + 1);
  void onPrevTap() => _emit(_value - 1);

  void _emit(int next) {
    if (next == _value) return;  // the duplicate filter
    _value = next;
    _changes.add(_value);
  }

  Future<void> dispose() => _changes.close();
}
```

## Recipe: domain state and ephemeral state together

Two sources, one view object. The rule that keeps it correct: every source only **triggers** a rebuild, and the object itself is built by the single `_createViewObject()` - the same method the `state` getter uses. One build path means `state` and the stream cannot diverge.

```dart
class FilterViewModel implements StateReadable<FilterViewObject> {
  FilterViewModel({required StateReadable<CatalogState> catalog}) : _catalog = catalog {
    _subscription = _catalog.stream.listen((_) => _emit());
  }

  final StateReadable<CatalogState> _catalog;
  final _changes = StreamController<FilterViewObject>.broadcast();
  late final StreamSubscription<CatalogState> _subscription;

  String _query = '';

  @override
  FilterViewObject get state => _createViewObject();

  @override
  Stream<FilterViewObject> get stream => _changes.stream;

  void onQueryChanged(String query) {
    if (query == _query) return;
    _query = query;
    _emit();
  }

  void _emit() => _changes.add(_createViewObject());

  FilterViewObject _createViewObject() => FilterViewObject(
        items: _catalog.state.items.where((item) => item.matches(_query)).toList(),
        query: _query,
      );

  Future<void> dispose() async {
    await _subscription.cancel();  // first the sources, then the controller
    await _changes.close();
  }
}
```

## A complex screen: many sources and a large view object

The shape does not change, only the number of subscriptions.

```dart
MainPageViewModel({...}) {
  for (final source in <Stream<Object?>>[
    _globalState.stream,
    _accountStatus.stream.distinct(),  // .distinct() on the noisy ones
    _ordersState.stream,
    // ...more sources...
  ]) {
    _subscriptions.add(source.listen((_) => _emit()));
  }
}

final _subscriptions = <StreamSubscription<Object?>>[];

Future<void> dispose() async {
  for (final subscription in _subscriptions) {
    await subscription.cancel();
  }
  await _changes.close();
}
```

- One list of sources, one listener that only triggers, one `_createViewObject()`.
- `shouldUpdate(previous, current)` is a method you write on the ViewModel yourself - nothing declares it - and it works as `buildWhen`: for a large view object pass it as `StateBuilder(buildWhen: viewModel.shouldUpdate)`, otherwise the widget rebuilds on every change of every source.

**The compromises of root screens (be aware of them, do not repeat them in a regular feature):** a `BuildContext` inside the ViewModel for dialogs and navigation; an oversized ViewModel with dozens of direct dependencies; lifecycle subscriptions placed in the presentation wiring. For a new feature keep the dependencies narrow.

## Which filter goes where

| Lever | Level | What it filters |
|---|---|---|
| the duplicate check inside `_emit` | the ViewModel's own state | writing and announcing a value that did not change |
| `.distinct()` on an input | one subscription | duplicates of that source, before the view object is rebuilt |
| `buildWhen` / `shouldUpdate` | the UI (`StateBuilder`) | the widget rebuild, by comparing the previous and the next view object |

```
source.stream -> [.distinct()] -> _emit() -> _createViewObject() -> vm.stream -> StateBuilder(buildWhen) -> rebuild
                                    ^                                                  ^
                        the duplicate check (own state only)                shouldUpdate(previous, current)
```

The domain side needs no filter of its own: a `StateManager` already filters its `emit` through `!=`.
