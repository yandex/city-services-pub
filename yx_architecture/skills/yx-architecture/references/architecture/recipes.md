# Recipe for a new feature plus the antipatterns

## Recipe: a new feature (Medium boundary)

1. **The data model.** Entities (`Order`, `Account`) become domain models. Raw payloads (`OrderDto`) become DTOs in data. The mapping becomes pure functions in the repository.
2. **Sources and repositories.** A repository is needed when a source is shared between state managers, or when you combine several sources. Otherwise the StateManager accesses the source directly.
3. **The business state.** Define **one** state for the feature - that is the `T` in `StateManager<T>`. Operations on it become methods built around `handle((emit) async {...})`.
4. **An Interactor?** One StateManager plus one source - not needed. Coordination (log in, then fetch the order, then update the map) - needed.
5. **The scope.** At which level of the scope tree is the feature placed? A separate scope or a `ScopeModule`? The rule is in the `yx-scope-fundamentals` skill.
6. **The UI.** Define the `ViewObject`. The ViewModel `implements StateReadable<ViewObject>` and is created by the screen widget in `initState`, not in a scope.
7. **Navigation.** Declare the route as `YxRoute(id: 'feature-xxx-home')`, wire it through `RouteDeclaration.routeBuilder`, and include it in the `RouterSchema`. The declaration types are in the `yx-navigation-fundamentals` skill.
8. **The linter.** `yx_scope_linter` checks the `Dep` suffix, `late final`, and dependency cycles.

## Antipattern catalog

| # | Antipattern | What to do instead |
|---|---|---|
| 1 | Mapping through a getter on the StateManager | map in the ViewModel with a pure function |
| 2 | A StateManager depends on another StateManager | coordinate through an Interactor |
| 3 | A Repository depends on a Repository | compose one level up |
| 4 | A Flutter import in Domain | pure Dart only |
| 5 | A Flutter import in a ViewModel | pure Dart only |
| 6 | A ViewModel in a DI scope | create it in the widget's `initState`, dispose it in `dispose` |
| 7 | A lazy `late` or getter in DI used as the source of truth | build the scope explicitly at startup |
| 8 | A feature package depending on a feature package | go through interfaces (the feature facade) |
| 9 | Ephemeral state shared by several view models | lift it into business state (a StateManager) |
| 10 | Framework state in a ViewModel | keep it in a `StatefulWidget` |
| 11 | Calling Interactor methods from a ViewModel subscription | a subscription changes only the ephemeral state of the ViewModel |
| 12 | The same data duplicated across business states | combine them through a StateProvider |

### Accessing a StateManager directly when an Interactor exists

If a StateManager is wrapped by an Interactor, go through the Interactor and do not access the StateManager directly. This is a review-level agreement: there is no package isolation mechanism for it yet, and the linter will not catch it.
