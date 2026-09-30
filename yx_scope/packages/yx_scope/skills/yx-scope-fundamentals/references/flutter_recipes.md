# yx_scope: Flutter, recipes, antipatterns

## Flutter integration

- **`ScopeProvider<AppScope>(holder:, child:)`** - passes a scope down the tree through an `InheritedWidget`. The holder is kept in the `State`, `create()` is called in `initState`, `drop()` in `dispose`.
- **`ScopeBuilder<AppScope>(builder: (ctx, scope) {...})`** - rebuilds when the scope changes; the `scope` the builder receives is nullable.
- **`ScopeBuilder<AppScope>.withPlaceholder(builder: (ctx, scope) {...}, placeholder:)`** - a non-null scope inside the builder.
- **`ScopeListener<AccountScope>(listener:, child:)`** - side effects without a rebuild.
- **`ScopeProvider.of<AppScope>(context)`** - imperative access.

The generic argument is always the **interface, not the container**: `ScopeBuilder<AppScope>`.

## Antipatterns

| # | Antipattern | Why |
|---|---|---|
| 1 | Keeping a `ScopeContainer` or `scope` in a field across an async gap | after the `await` the scope may already be closed, which means a crash or stale data |
| 2 | Adding a `Dep` dynamically at runtime | not compile-safe, and the graph is lost |
| 3 | A scope whose lifetime matches its parent | that case needs a `ScopeModule` |
| 4 | Passing a container or a holder into a widget | only the scope interface goes outward |
| 5 | Cycles between deps | the linter reports `dep_cycle` |
| 6 | Passing a parent scope transitively into a child parent interface | breaks isolation |
| 7 | An `asyncDep` missing from `initializeQueue` | it never initializes |
| 8 | Initializing a service from its constructor through `_init()` | non-deterministic - use `asyncDep` |
| 9 | `ScopeHolder<Container>` without an interface | in production use `BaseScopeHolder<Interface, Container>` |
| 10 | `appScope.someManagerDep.get` from the outside | a `Dep` is private - expose a getter through the interface |

Staying safe across an async gap: check again after every await - `final s = holder.scope; if (s == null) return; await ...; final s2 = holder.scope; if (s2 == null) return;`.

## The linter

`yx_scope_linter` catches `consider_dep_suffix` (the `Dep` suffix), `final_dep` (`late final`), `dep_cycle` (cycles), and async deps that are never initialized.

```yaml
dev_dependencies:
  yx_scope_linter: ^0.2.0
  custom_lint: ^0.7.0
# analysis_options.yaml -> analyzer.plugins: [custom_lint]
```

Not automated, so check these manually: picking the kind of scope, the "scope versus module versus neither" decision, using interfaces, and staying safe across async gaps.

## Recipe: the root AppScope

```dart
abstract class AppScope implements Scope {
  RouterDelegate get routerDelegate;
  AppStateObserver get appStateObserver;
}

class AppScopeContainer extends ScopeContainer implements AppScope {
  // asyncDep requires the value to implement AsyncLifecycle (init/dispose).
  // For a class that does not, use rawAsyncDep with explicit callbacks - see advanced.md.
  late final _databaseDep = asyncDep(() => Database());
  @override
  List<Set<AsyncDep>> get initializeQueue => [{_databaseDep}];

  late final _routerDelegateDep = dep(() => AppRouterDelegate());
  late final _appStateObserverDep = dep(() => AppStateObserver(_databaseDep.get));
  late final accountScopeHolderDep = dep(() => AccountScopeHolder(this));

  @override
  AppRouterDelegate get routerDelegate => _routerDelegateDep.get;
  @override
  AppStateObserver get appStateObserver => _appStateObserverDep.get;
}

class AppScopeHolder extends BaseScopeHolder<AppScope, AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
```

## Recipe: a child scope (ChildDataScope)

```dart
abstract class AccountScope implements Scope {
  AccountManager get accountManager;
}
abstract class AccountScopeParent implements Scope {
  Database get database;  // what it needs from the parent
}

class AccountScopeContainer
    extends ChildDataScopeContainer<AccountScopeParent, Account>
    implements AccountScope {
  AccountScopeContainer({required super.parent, required super.data});
  late final _accountManagerDep = dep(() => AccountManager(data, parent.database));
  @override
  AccountManager get accountManager => _accountManagerDep.get;
}

class AccountScopeHolder
    extends BaseChildDataScopeHolder<AccountScope, AccountScopeContainer, AccountScopeParent, Account> {
  AccountScopeHolder(super.parent);
  @override
  AccountScopeContainer createContainer(AccountScopeParent parent, Account data) =>
      AccountScopeContainer(parent: parent, data: data);
}
```

The parent implements `AccountScopeParent`:

```dart
class AppScopeContainer extends ScopeContainer implements AppScope, AccountScopeParent {
  @override
  Database get database => _databaseDep.get;
}
```

## Recipe: wiring into Flutter

```dart
class _AppState extends State<App> {
  final _appScopeHolder = AppScopeHolder();

  @override
  void initState() {
    super.initState();
    _appScopeHolder.create();
  }
  @override
  void dispose() {
    _appScopeHolder.drop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ScopeProvider<AppScope>(
      holder: _appScopeHolder,
      child: ScopeBuilder<AppScope>.withPlaceholder(
        builder: (context, appScope) => MaterialApp.router(
          routerDelegate: appScope.routerDelegate,
        ),
        placeholder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
```
