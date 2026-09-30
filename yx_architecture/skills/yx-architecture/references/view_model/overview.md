# The ViewModel contract

A ViewModel is the presentation object of one screen or one widget. It maps business state into a **view object** that is ready to render, and it carries the user's intent back into domain. No Flutter inside - pure Dart. Recipes, the emit filters and the antipatterns are in [recipes.md](recipes.md).

## There is no base class

A ViewModel implements `StateReadable<T>` from `yx_state` - the same two-member interface a `StateManager` exposes outward:

```dart
abstract class StateReadable<State extends Object?> {
  Stream<State> get stream;
  State get state;
}
```

That is the whole contract. No package to install, no file to copy, nothing to extend. Whatever else the ViewModel needs - a constructor, a `dispose()`, handler methods for the UI - are ordinary members that you write yourself.

Implementing that interface is what makes a ViewModel work with the widgets of `yx_state_flutter` unchanged:

```dart
StateBuilder<OrderViewObject>(stateReadable: viewModel, builder: (context, viewObject, child) => ...);
```

`StateListener`, `StateConsumer` and `StateSelector` take the same `stateReadable:` argument.

## What each member has to guarantee

| Member | Guarantee | Why |
|---|---|---|
| `state` | readable at any moment, cheap, never throws | `StateBuilder` reads it in `initState` to build the first frame, before any event arrives |
| `stream` | emits **changes**; the current value is not replayed on subscription | the first frame already came from `state`; a replay would only cause an extra rebuild |
| `stream` | tolerates more than one listener | one `StateBuilder` is one subscription, and a screen usually has several |

The third row is the only trap. `Stream.map` over a broadcast stream stays broadcast, so proxying a `StateManager` needs nothing extra. A controller you create yourself has to be `StreamController.broadcast()`.

One consequence for tests: a controller delivers in a microtask, not synchronously. In production that is invisible - the rebuild lands in the next frame - but in a widget test the `pump()` right after a synchronous handler call still shows the old value. Pump once more, or use `pumpAndSettle`.

## The view object

A view object is a presentation model: exactly the data one piece of UI renders, in the form it renders it - strings already formatted, flags already computed. It is built by a **pure function** of the business state.

- Keep the mapping pure and cheap. It runs on every rebuild and on every emit.
- Build it in **one method** and call that method from both `state` and every emit. Two build paths drift apart.
- Model the empty and the loading cases as explicit values of the view object, not as `null`.

## Who creates a ViewModel and who disposes it

The ViewModel lives as long as the piece of UI it serves, which is shorter than any scope. So it is **created by the widget that shows it and disposed by the same widget** - and it is never registered as a `dep`:

```dart
class _CatalogScreenState extends State<CatalogScreen> {
  late final FilterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FilterViewModel(catalog: widget.scope.catalogState);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StateBuilder<FilterViewObject>(
        stateReadable: _viewModel,
        builder: (context, viewObject, child) => CatalogView(viewObject),
      );
}
```

`dispose()` here is an ordinary method - no interface declares it, and `FilterViewModel`
([recipes.md](recipes.md)) defines it because it owns a subscription and a controller. A ViewModel
that only maps another `StateReadable` owns nothing, needs no `dispose()`, and then the widget's
`dispose` override goes away with it. Forgetting it when it is needed leaks the subscription: it
outlives the screen and keeps rebuilding a dead widget.

The dependencies come from the scope, read through a `ScopeProvider` or passed down by the caller. What comes out of DI are the **interactors and the `StateReadable`s** the ViewModel reads; the ViewModel itself is assembled from them on the spot.

## Links to the rest of the layers

- **Depends on** interactors (to issue commands) and on `StateReadable`s of domain state managers (to read). **Not** on a `StateManager` directly, apart from the documented exceptions, and **not** on Data.
- **Does not depend on another ViewModel.** Shared logic belongs in domain.
- Holds **ephemeral** state only - what is being typed, which tab is open, whether a sheet is expanded. Business state belongs to a `StateManager` in domain.

```
StateManager (domain) --StateReadable--> ViewModel (pure mapping) --StateReadable--> StateBuilder (UI)
Interactor   (domain) <--commands------- ViewModel (onTap, onSubmit, ...)
```
