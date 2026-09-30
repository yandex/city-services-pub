# Feature facade: an embeddable module

`Feature` (the feature controller) is the only public entry point a feature package exposes to its host.

Below, `Xxx` is the feature name in PascalCase and `xxx` is the same name in snake_case.

**When you need it:** the feature is a separate package; several teams share one application; common modules are reused. **When you do not:** a small single-team feature that lives in the same package as the host; a prototype.

## What a Feature does

1. It is the only public entry point of the feature. Everything it exposes goes **only** through `XxxOutputDeps`.
2. One logical feature has one `XxxFeature` class.
3. Lifecycle: `init()` calls `create()` on the main `ScopeHolder` and starts the logic that runs for the whole lifetime of the feature; `dispose()` calls `drop()`. The host calls both. The lifetime of the feature equals the lifetime of the host scope it lives in.
4. It takes `XxxInputDeps` through the constructor. A feature **does not depend** on another feature directly - only through the host.
5. It owns its internal DI built on `yx_scope` - a single `ScopeHolder`.

To the host the feature is a grey box: the host provides the dependencies, uses what the feature exposes, and does not depend on the internals.

```
   Host --> InputDeps ------> Feature
                                 |
                                 +--> OutputDeps        --> Host (uses it)
                                 `--> init() / dispose() <-- Host (owns the lifecycle)
```

## Contracts

| Contract | Kind | When | Purpose |
|---|---|---|---|
| `XxxInputDeps` | a plain class | always | what the feature needs from the host: navigation delegates, the `StateReadable`s of other features, services. The feature passes them into its `ScopeContainer` |
| `XxxOutputDeps` | `abstract interface class` | as needed | everything the feature exposes: states (`StateReadable<...>`), `widgetFactory`, optional interactors. `XxxFeature implements XxxOutputDeps` |
| `XxxWidgetFactory` | `abstract interface class` | when there is UI | the `buildXxx(...)` methods. Exposed **through `XxxOutputDeps`** (the `widgetFactory` getter), not implemented on `XxxFeature` directly |
| `XxxSomeInteractor` | `abstract interface class` | as needed | imperative commands from the host ("reset", "reload"). A narrow contract for one role. Exposed through `XxxOutputDeps` |

Expose outward-facing entities **only** through `XxxOutputDeps` - no ad-hoc public getters and no `as` casts.

**Features interact only through the host:**
- **Data:** the host builds an adapter over the `StateReadable` of one feature (`.map(...)`, see "Appendix: MappedStateReadable" at the end of this file) and passes it into the `InputDeps` of another.
- **Navigation:** the feature declares delegate interfaces (`XxxNavigatorDelegate`, `XxxEntryPointDelegate`); the host implements all of them in a single navigator class (`HostNavigator`).

Navigation inside a feature is its own `RouterSchema` plus `RouteNodeStateManager` plus `routerConfig` in the feature scope (the entities are covered by the `yx-navigation-fundamentals` skill).

## The simple case: one ScopeHolder

Use it when the feature is **not parameterized**. `widgetFactory` is a `late final` field on `XxxFeature`, built from `DefaultXxxWidgetFactory`.

```dart
class XxxFeature implements XxxOutputDeps {
  XxxFeature({required XxxInputDeps inputDeps})
      : _scopeHolder = XxxScopeHolder(inputDeps: inputDeps);
  final XxxScopeHolder _scopeHolder;

  Future<void> init() => _scopeHolder.create();
  Future<void> dispose() => _scopeHolder.drop();

  // OutputDeps. The `!` is acceptable here: the host must call init() before accessing this
  @override
  StateReadable<XxxState> get xxxState => _scopeHolder.scope!.stateManager;

  @override
  late final XxxWidgetFactory widgetFactory =
      DefaultXxxWidgetFactory(scopeHolder: _scopeHolder);
}

abstract interface class XxxOutputDeps {
  StateReadable<XxxState> get xxxState;
  XxxWidgetFactory get widgetFactory;
}

abstract interface class XxxWidgetFactory {
  Widget buildScreen();
}

// the feature holder is a ScopeHolder<Container>, not a BaseScopeHolder
class XxxScopeHolder extends ScopeHolder<XxxScopeContainer> {
  XxxScopeHolder({required XxxInputDeps inputDeps}) : _inputDeps = inputDeps;
  final XxxInputDeps _inputDeps;

  @override
  XxxScopeContainer createContainer() => XxxScopeContainer(inputDeps: _inputDeps);
}

// the internal interface: only the internal deps of the feature, no widgetFactory
abstract interface class XxxScope {
  XxxStateManager get stateManager;
  XxxNavigator get navigator;
  YxRouterConfig get routerConfig;
}

class XxxScopeContainer extends ScopeContainer implements XxxScope {
  XxxScopeContainer({required XxxInputDeps inputDeps}) : _inputDeps = inputDeps;
  final XxxInputDeps _inputDeps;
  // dep/asyncDep: api, stateManager, routerSchema, navigationStateManager,
  // routerConfig, navigator plus initializeQueue
}

// depends on the abstract ScopeStateHolder<XxxScope>, not on the concrete XxxScopeHolder
class DefaultXxxWidgetFactory implements XxxWidgetFactory {
  const DefaultXxxWidgetFactory({required ScopeStateHolder<XxxScope> scopeHolder})
      : _scopeHolder = scopeHolder;
  final ScopeStateHolder<XxxScope> _scopeHolder;

  @override
  Widget buildScreen() => ScopeProvider<XxxScope>(
        holder: _scopeHolder,
        child: ScopeBuilder<XxxScope>.withPlaceholder(
          placeholder: XxxScreen.loading(),
          builder: (_, scope) => XxxScreen(scope: scope),
        ),
      );
}
```

`XxxFeature` **does not** keep `XxxInputDeps` as a field - the holder is built directly from `inputDeps` in the constructor and passes them into the container. `XxxScope`, the internal interface, holds only internal deps, and `widgetFactory` is **not** one of them. Passing `_scopeHolder` into the factory is valid: `ScopeHolder<XxxScopeContainer>` is a `ScopeStateHolder<XxxScopeContainer>`, which is assignable to `ScopeStateHolder<XxxScope>`.

If the feature has **nothing to expose** (it only reacts to host navigation and renders its own screens), do not introduce an empty `XxxOutputDeps` - `XxxFeature` stays a plain class with `init()` and `dispose()`.

## Checklist for a new feature

1. **`XxxInputDeps`** (a plain class) - navigation delegates, the `StateReadable`s of other features, services.
2. **`XxxOutputDeps`** (`abstract interface class`) - states plus `widgetFactory` plus optional interactors. Skip it when there is nothing to expose.
3. **`XxxWidgetFactory`** plus **`DefaultXxxWidgetFactory`** *(when there is UI)*.
4. **`XxxSomeInteractor`** *(as needed)* - a narrow interface for one role.
5. **`XxxScope` / `XxxScopeContainer` / `XxxScopeHolder`** - the internal DI. The scope interface holds only internal things (state managers, the navigator, `routerConfig`). The holder is a `ScopeHolder<XxxScopeContainer>`.
6. **`XxxFeature implements XxxOutputDeps`** - takes `InputDeps`, owns `_scopeHolder`, maps `init()` to `create()` and `dispose()` to `drop()`, exposes state from the live scope, and keeps `widgetFactory` as a `late final` field.
7. **Wiring into the host** (see below).

## Wiring into the host

In the DI container of the host (`host_scope_container.dart`):

- The feature controller becomes `rawAsyncDep(() => XxxFeature(inputDeps: ...), init: (c) => c.init(), dispose: (c) => c.dispose())` plus an entry in `initializeQueue`.
- When navigation is needed, implement the feature delegates in `HostNavigator`.
- When one feature exposes state for another, build the adapter `featureA.xxxState.map(...)` and pass it into the `InputDeps` of feature B.
- Screen routes go into the `RouterSchema` of the host: pass `controller.widgetFactory` and call `widgetFactory.buildXxx(...)`.

## Review and migration checklist

- [ ] A logical feature has **one** `XxxFeature` with `init()` and `dispose()`.
- [ ] If it exposes anything, `XxxFeature implements XxxOutputDeps` and **only** that (not `XxxWidgetFactory` directly). If there is nothing to expose, there is no `XxxOutputDeps`.
- [ ] The `XxxScope` interface holds **only** internal deps (state managers, the navigator, `routerConfig`) - no `widgetFactory` and no outward-facing contracts.
- [ ] `widgetFactory` is a `late final` field on `XxxFeature` (`DefaultXxxWidgetFactory(scopeHolder: _scopeHolder)`).
- [ ] `DefaultXxxWidgetFactory` depends on `ScopeStateHolder<XxxScope>`, not on the concrete holder.
- [ ] The feature holder is a `ScopeHolder<XxxScopeContainer>`.
- [ ] The `pubspec.yaml` of the feature has **no** dependency on another `*_feature` package.
- [ ] `XxxFeature` contains no business logic (only pass-through from the scope), no `BuildContext`, and no layout.
- [ ] Links to other features go only through `InputDeps` plus delegate and adapter implementations on the host side.

## What must NOT be in a Feature

- **Business logic** - it belongs in a `StateManager` or in services inside the scope.
- **Direct knowledge of other features** - only through `InputDeps` and the host.
- **UI, `BuildContext`, layout** - the feature provides a widget through its `WidgetFactory`, but it does not lay out anything itself and does not hold a context.

## Appendix: MappedStateReadable

The adapter the host uses to narrow the state of one feature to the `InputDeps` of another. `yx_state` does not include this extension; the host implements it. Copy it into your project.

```dart
import 'package:yx_state/yx_state.dart';

class _MappedStateReadable<T, R> implements StateReadable<R> {
  final StateReadable<T> _source;
  final R Function(T) _mapper;

  _MappedStateReadable({
    required StateReadable<T> source,
    required R Function(T) mapper,
  })  : _source = source,
        _mapper = mapper;

  @override
  R get state => _mapper(_source.state);

  @override
  Stream<R> get stream => _source.stream.map(_mapper);
}

extension MappedStateReadableExtension<T> on StateReadable<T> {
  StateReadable<R> map<R>(R Function(T) mapper) => _MappedStateReadable<T, R>(
        source: this,
        mapper: mapper,
      );
}
```

The host owns the adapter and passes the result into `InputDeps`: `featureA.xxxState.map((s) => s.onlyWhatBNeeds)`. Feature B receives a narrow `StateReadable` and knows nothing about feature A.
