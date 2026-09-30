# yx_scope: DI and scopes

DI with no statics and no code generation. The entry point: the concepts, the kinds of scopes, and when to introduce a scope. Interfaces and async dependencies are in [advanced.md](advanced.md). Flutter, recipes and antipatterns are in [flutter_recipes.md](flutter_recipes.md).

## Concepts

- **`Dep<T>`** - a wrapper around a dependency instance. Lazy, and unique within its container. Access it through `.get`. It exists **only inside a ScopeContainer** and is never exposed outward.
- **`ScopeContainer`** - an isolated set of deps that share one lifetime. It declares the dependency graph declaratively.
- **`ScopeHolder`** - owns the lifecycle of a container: `create()` builds it and initializes the async deps, `drop()` closes it. Before `create()` the `scope` field is `null`.
- **`ScopeModule`** - a group of dependencies **inside** a container, without a lifecycle of its own. It accesses the parent through `container`. It does not create a new scope.
- **The scope tree** - a hierarchy of scope holders. The holder of a child scope is declared as a `dep` in the container of its parent.

**The key idea:** the UI does not create scopes; scopes create the UI. A container exists independently of the widget tree, and widgets subscribe to a scope that already exists.

## Kinds of scopes

Choose by two criteria: does it have a parent, and does it require input data.

| Kind | When | Example |
|---|---|---|
| `ScopeContainer` plus `ScopeHolder` | the root: no parent, no data | `AppScope` |
| `ChildScopeContainer<Parent>` plus `ChildScopeHolder` | there is a parent, no data | `OnlineScope` |
| `DataScopeContainer<T>` plus `DataScopeHolder` | no parent, data required | rare |
| `ChildDataScopeContainer<Parent, T>` plus `ChildDataScopeHolder` | a parent and data | `AccountScope` (the data is an `Account`) |

Pass the data through `super.data` (or `super.parent`) in the constructor; read it from the `data` (or `parent`) field.

## When to introduce a scope, a ScopeModule, or neither

**Introduce a scope** when a group of dependencies has **clear start and end conditions** that differ from the others. Examples: `AccountScope` (log in to log out), `OrderScope` (order received to order closed).

**Introduce a ScopeModule** when the lifetime of the group **matches an existing scope exactly**, but the dependencies are logically separate. Example: everything about routing inside `AppScope` becomes a `RoutingAppScopeModule`.

```dart
class AppScopeContainer extends ScopeContainer {
  late final accountScopeHolderDep = dep(() => AccountScopeHolder(this));
  late final routingModule = RoutingAppScopeModule(this);
}

class RoutingAppScopeModule extends ScopeModule<AppScopeContainer> {
  RoutingAppScopeModule(super.container);

  late final routerDelegateDep = dep(() => AppRouterDelegate());
  late final appStateObserverDep = dep(
    () => AppStateObserver(routerDelegateDep.get, container.accountScopeHolderDep.get),
  );
}
```

**Introduce neither** when the condition that would create the group is unclear, or when the group has exactly the same lifetime as an existing scope - that case is a `ScopeModule`.

**Parent and child versus siblings:** parent and child means one lifetime is strictly nested inside the other, so the child closes together with the parent. Siblings means two lifetimes may overlap in any order, for example `AccountScope` and `RegisterScope` under a shared `AppScope`.
