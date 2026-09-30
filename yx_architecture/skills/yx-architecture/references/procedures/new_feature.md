# Procedure: plan a new feature

Follow this when the user asks how to lay out a new feature on the yx stack, whether they said it in
prose or ran `/yx-architecture:yx-new-feature`.

You need two things before planning: the feature name in `snake_case` and one line on what it does.
**Do not guess the name** - it ends up in the package name, the folder tree and the route ids. Ask
for whichever is missing.

**Do not report on which skills are installed when they all are.** Mention a missing companion skill
only where its absence changes the answer, and keep it to one line.

## Step 1: answer the pre-flight checklist

The three questions come from `../../SKILL.md`. Answer each one explicitly and say why.

1. **Which Data-Domain boundary?** Read `../architecture/data_domain.md`. The default is Medium.
   Take Hard only for a large or long-lived feature; take Easy only for a prototype, and state
   explicitly that it is a compromise.
2. **Is this an embeddable module?** Read `../feature_facade/overview.md` if the feature is a
   separate package, several teams share the app, or it is a common module.
3. **A separate scope, a ScopeModule, or neither?** The test is whether the group of dependencies
   has start and end conditions of its own; for the full rule load the `yx-scope-fundamentals` skill
   and read its `references/overview.md`; if that skill is not installed, say so and suggest
   `fvm dart run skills@ get --agent <agent>`.

## Step 2: define the single business state

One feature, one business state - that is the `T` in `StateManager<T>`. Write it as a type with its
fields, and say what each operation does to it.

Distinguish the three kinds of state: business state goes into the StateManager, service state into
plain fields, ephemeral state into the ViewModel. For the strategies and the handler rules load the
`yx-state-fundamentals` skill and read its `references/overview.md`; if that skill is not installed,
say so and suggest `fvm dart run skills@ get --agent <agent>`.

## Step 3: lay out the layers

Follow the folder structure from `../architecture/overview.md` and the eight-step recipe in
`../architecture/recipes.md`.

## Output

**A decision record** - the first thing in the answer, four lines, no prose before it. An assumption
about the project goes into the `because` column of the line it affects, or into a single line right
after the record - never ahead of it:

```
boundary:   Medium | Easy | Hard    because ...
facade:     yes | no                because ...
scope:      separate scope | ScopeModule | neither    because ...
state:      XxxState { field: Type, ... }
```

**The folder tree** for the feature, filled in with real file names.

**A file list with signatures** - the skeleton of each class that has to be written, with its
constructor parameters and public methods. No implementations.

**The route**: the `YxRoute` id with a feature prefix, and which declaration factory to use. For the
factories load the `yx-navigation-fundamentals` skill and read its `references/recipes.md`; if that
skill is not installed, say so and suggest `fvm dart run skills@ get --agent <agent>`.

Stop at this point. Do not write the implementation unless the user asks for it.

That means: no method bodies anywhere in the answer, not even a short one that looks obvious - not
in the state manager, not in the view model, not in the api, not in the mapper. A signature ends at
the closing parenthesis and the return type. Dependency registration and the route declaration are
wiring, not method bodies, and are expected.

## Example output

For the feature `order_history`, "shows the list of completed orders":

```
boundary:   Medium            because one endpoint, one domain model of its own, no multi-team contract
facade:     no                because the feature lives in the same package as the host
scope:      neither           because the history lives as long as the account: two deps go into the existing AccountScope
state:      OrderHistoryState { orders: List<Order>, isLoading: bool, error: Object? }
```

```
order_history/lib/
|-- data/
|   |-- api/order_history_api.dart
|   `-- mapper/order_mapper.dart            # pure functions, OrderDto -> Order
|-- domain/
|   |-- model/order.dart
|   `-- state_manager/order_history_state_manager.dart
`-- presentation/
    |-- view_model/order_history_view_model.dart
    `-- screen/order_history_screen.dart
```

```dart
class OrderHistoryApi { Future<List<OrderDto>> fetchCompleted(); }
Order mapOrderDto(OrderDto dto);                                                        // data/mapper, pure
class OrderHistoryStateManager extends StateManager<OrderHistoryState> { Future<void> load(); }
class OrderHistoryViewModel implements StateReadable<OrderHistoryViewObject> { void onRetryTap(); }
```

No repository: one source and one state manager, so the manager calls the api directly and maps
through the pure function (`../architecture/recipes.md`, step 2). No interactor: one state manager,
nothing to coordinate (step 4).

Route: `YxRoute(id: 'order-history-list')`, declared with `RouteDeclaration.routeBuilder` and
`RouteBuilder.widget`.

DI in `AccountScopeContainer`: `rawAsyncDep(() => OrderHistoryStateManager(_apiDep.get), init: (_)
async {}, dispose: (m) => m.close())`, added to `initializeQueue`. The `init` is empty on purpose -
the history loads when the screen opens, not when the account scope starts. The ViewModel is created
by the screen widget in `initState` and disposed in `dispose`, not in the scope.

Keep the same blocks in the same order: the decision record, the tree, the signatures, the route,
the DI note. The names change, the shape does not.
