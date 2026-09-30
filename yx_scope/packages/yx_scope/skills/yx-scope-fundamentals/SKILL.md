---
name: yx-scope-fundamentals
description: >
  Apply the yx_scope rules when working with Dart or Flutter code that uses the yx_scope dependency injection package. Trigger in any of these cases: (1) the user names yx_scope, ScopeContainer, ScopeHolder, ChildScopeContainer, DataScopeContainer, ScopeModule, Dep, AsyncDep, ScopeProvider, ScopeBuilder or ScopeListener; (2) the code imports package:yx_scope or package:yx_scope_flutter; (3) the user asks how to wire dependencies, scopes or their lifetimes in an app built on this package.
  Do NOT apply to general dependency injection questions about get_it, provider, riverpod or injectable when no yx_scope code is involved.
license: MIT
---

# yx_scope: dependency injection without code generation

Scopes are groups of dependencies that share a lifetime. A container declares the graph, a holder
creates and drops it, and nothing is static or generated.

## Principles (cheat sheet)

Details are in the references below; read one file, not all three.

1. **A `Dep` never leaves its container.** It is lazy, unique inside the container, and read through
   `.get`. What leaves the container is a public scope interface, not the deps themselves.
2. **A separate scope needs start and end conditions of its own.** If the lifetime matches the parent
   exactly, the answer is a `ScopeModule`, not a new scope.
3. **A child depends on a parent interface**, never on the parent container class. That is what keeps
   a scope replaceable and testable.
4. **Async dependencies are initialized in order.** Declare them with `asyncDep` or `rawAsyncDep` and
   list them in `initializeQueue`; a missing entry means the dep is never initialized.
5. **Scopes create the UI, not the other way round.** A container exists independently of the widget
   tree, and widgets subscribe to a scope that already exists.
6. **In production use `BaseScopeHolder` with an interface**, not `ScopeHolder<Container>`. The short
   form belongs to getting-started examples.

## References index - topic to file

| Topic | File |
|---|---|
| Concepts, kinds of scopes, when a scope is justified | `references/overview.md` |
| Scope and parent interfaces, `BaseScopeHolder`, async dependencies, holder patterns | `references/advanced.md` |
| `ScopeProvider`, `ScopeBuilder`, `ScopeListener`, recipes, the linter, ten antipatterns | `references/flutter_recipes.md` |

## Beyond this skill

This skill covers the package itself. How a scope fits into the layers of an application, where an
Interactor belongs, and what an embeddable feature module exposes to its host are described by the
`yx-architecture` skill. Install it from
https://github.com/yandex/city-services-pub/tree/main/yx_architecture when that context is needed.

The state management and navigation packages of the same stack ship their own skills,
`yx-state-fundamentals` and `yx-navigation-fundamentals`. Install them with
`fvm dart run skills@ get --agent <your agent>` when the project depends on those packages.
