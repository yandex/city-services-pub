# yx_scope: interfaces and async dependencies

## Working through Scope and ScopeParent interfaces

Every public container exposes an interface. The deps stay private and only getters go outward.

```dart
abstract class AccountScope implements Scope {
  AccountManager get accountManager;
  OrderStateHolder get orderStateHolder;
}

class AccountScopeContainer extends ChildDataScopeContainer<AccountScopeParent, Account>
    implements AccountScope {
  AccountScopeContainer({required super.parent, required super.data});

  late final _accountManagerDep = dep(() => AccountManager(data));
  late final _orderScopeHolderDep = dep(() => OrderScopeHolder(this));

  @override
  AccountManager get accountManager => _accountManagerDep.get;
  @override
  OrderStateHolder get orderStateHolder => _orderScopeHolderDep.get;
}
```

Why: it hides `Dep` from the consumer, keeps presentation unaware of yx_scope, and allows a child to be moved between parents.

### ScopeParent - the interface of what a child expects from its parent

A child scope depends **on an interface of its parent**, not on a concrete container.

```dart
abstract class OnlineScopeParent implements Scope {
  OrderStateHolder get orderStateHolder;
}
abstract class OnlineScope implements Scope {
  AcceptOrderManager get acceptOrderManager;
}
class OnlineScopeContainer extends ChildScopeContainer<OnlineScopeParent>
    implements OnlineScope {
  OnlineScopeContainer({required super.parent});
  late final _acceptOrderManagerDep = dep(() => AcceptOrderManager(parent.orderStateHolder));
  @override
  AcceptOrderManager get acceptOrderManager => _acceptOrderManagerDep.get;
}
```

The parent implements that interface: `class AccountScopeContainer ... implements AccountScope, OnlineScopeParent`.

**Do not pass parent scopes transitively down** - `OnlineScopeParent` must not carry a getter for `AccountScopeParent`. That breaks isolation.

### BaseScopeHolder instead of ScopeHolder

To expose the scope interface instead of the container, the holder extends `BaseScopeHolder<Interface, Container>`:

```dart
class AppScopeHolder extends BaseScopeHolder<AppScope, AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
// for a child, the third parameter is the parent interface, not the parent container
class OnlineScopeHolder
    extends BaseChildScopeHolder<OnlineScope, OnlineScopeContainer, OnlineScopeParent> {
  OnlineScopeHolder(super.parent);
  @override
  OnlineScopeContainer createContainer(OnlineScopeParent parent) =>
      OnlineScopeContainer(parent: parent);
}
```

In production always use `BaseScopeHolder` with an interface and a parent interface, never `ScopeHolder<Container>`.

> **The exception is the simple feature facade case.** There the main feature scope uses `ScopeHolder<XxxScopeContainer>`; the facade contracts are described by the `yx-architecture` skill. Regular app scopes use `BaseScopeHolder`.

### Holder implements Logic (an advanced pattern)

A holder may implement a domain interface - then business logic depends on a domain API without knowing about scopes at all:

```dart
abstract class OnlineOrderStateHolder {
  Future<void> toggle();
}
class OnlineScopeHolder
    extends BaseChildScopeHolder<OnlineScope, OnlineScopeContainer, OnlineScopeParent>
    implements OnlineOrderStateHolder {
  OnlineScopeHolder(super.parent);
  @override
  OnlineScopeContainer createContainer(OnlineScopeParent parent) =>
      OnlineScopeContainer(parent: parent);
  @override
  Future<void> toggle() async {
    if (scope == null) { await create(); } else { await drop(); }
  }
}
```

## Async dependencies

Declare a dependency with asynchronous initialization (opening a database, warming a cache) as `asyncDep` or `rawAsyncDep`, and **always** add it to `initializeQueue`.

```dart
// the class implements AsyncLifecycle (init/dispose)
class AppScopeContainer extends ScopeContainer {
  late final myServiceDep = asyncDep(() => MyService());
  @override
  List<Set<AsyncDep>> get initializeQueue => [{myServiceDep}];
}

// a class without AsyncLifecycle - rawAsyncDep with explicit init and dispose
late final databaseDep = rawAsyncDep(
  () => Database(),
  init: (db) async => db.open(),
  dispose: (db) async => db.close(),
);
```

`initializeQueue` is a `List<Set<AsyncDep>>`: inside one `Set` the deps initialize in parallel through `Future.wait`, and the sets run one after another.

**The ordering rule:** when one async dep needs the result of another, put it in a **later** set and put the one it needs in an earlier set. The sets initialize strictly in order, so by the time the dependent one starts, everything it needs is ready. Put independent deps into the same `Set` so they initialize in parallel.

```dart
@override
List<Set<AsyncDep>> get initializeQueue => [
  {databaseDep, networkDep},  // independent -> in parallel, in one set
  {cacheDep},                 // needs databaseDep -> in a later set
];
```

**CRITICAL:** an `asyncDep` that is missing from `initializeQueue` never initializes. Once a scope is available (`holder.scope != null`), all of its async deps are ready - no null checks needed inside.
