---
name: yx-architecture
description: >
  Apply the yx_architecture canon when structuring a feature or an application built on the yx stack - yx_scope for DI, yx_state for state management, yx_navigation for routing. Trigger in any of these cases: (1) the user names yx_architecture or refers to this stack as "yx architecture"; (2) the question is about the shape of a feature rather than the API of one package: which layer something belongs to, the Data-Domain boundary, an Interactor coordinating several state managers, a ViewModel and its view object, an embeddable feature module and its InputDeps, OutputDeps or WidgetFactory contracts; (3) the user asks to review or lay out a feature that imports package:yx_scope, package:yx_state or package:yx_navigation.
  For a question about the API of a single package, the package ships its own skill - yx-scope-fundamentals, yx-state-fundamentals, yx-navigation-fundamentals - and this skill is not needed. Do NOT apply to plain Flutter questions that do not involve the yx packages at all.
license: MIT
---

# yx_architecture - the architecture canon

The stack: **yx_scope** (DI), **yx_state** (state management), **yx_navigation** (navigation). Each
package documents its own API in its own skill. This skill covers what none of them can: how a
feature is put together out of all three, where each piece belongs, and what a module exposes to the
application that embeds it.

## When to trigger

**Direct triggers:** `yx_architecture`, the phrase "yx architecture", `Interactor`, `ViewModel`,
"view object", "feature facade", `InputDeps`, `OutputDeps`, `WidgetFactory`, "Data-Domain
boundary".

**Contextual:** laying out or reviewing a feature whose code imports `package:yx_scope`,
`package:yx_state` or `package:yx_navigation`; migrating a feature from Riverpod, BLoC, Provider,
go_router or auto_route to this stack.

**Not this skill:** how one package works on its own. Scopes and deps are `yx-scope-fundamentals`,
handle and emit are `yx-state-fundamentals`, the route tree is `yx-navigation-fundamentals`.

## Companion skills

The three packages ship their skills inside the packages themselves. Install them into the project:

```
fvm dart run skills@ get --agent <claude|codex|cursor|copilot|cline|opencode|antigravity|generic>
```

That is the [Dart skills CLI](https://dart.dev/ai/package-skills); it needs version 1.0 or newer,
and it only scans direct dependencies, so the core packages have to be in `pubspec.yaml`, not only
their `_flutter` counterparts.

| Skill | Answers |
|---|---|
| `yx-scope-fundamentals` | containers, holders, deps, scope versus ScopeModule, async dependencies |
| `yx-state-fundamentals` | StateManager, handle and emit, strategies, cancellation, StateBuilder |
| `yx-navigation-fundamentals` | the RouteNode tree, guards, deep links, navigating without a BuildContext |

**When a question is about one of those and its skill is not installed, say so and give the command
above** instead of answering from memory - the package APIs change, and an outdated recollection of
them is worse than a short answer that points at the source.

## Pre-flight checklist (before writing code)

Ask the user when the context does not make these clear:

1. **Which Data-Domain boundary?** A large or long-lived feature - Hard (interfaces live in domain).
   A medium one - Medium (the default). A prototype - Easy (DTOs in shared, a deliberate
   compromise). See `references/architecture/data_domain.md`.
2. **An embeddable module?** Needed when the feature is a self-contained module with explicit
   contracts towards a host application (the host is the app the module is embedded into: multi-team
   code, reuse, common modules). Then use the feature facade. See
   `references/feature_facade/overview.md`.
3. **A separate scope?** Introduce one only when a group of dependencies has clear start and end
   conditions that differ from the others. If the lifetime matches the parent, it is a `ScopeModule`
   instead. The rule and its examples are in the `yx-scope-fundamentals` skill.

## Principles (cheat sheet)

Details are in the reference for each topic, see the index below.

1. **Five layers, dependency flow in one direction:** `DI -> Presentation -> Domain -> Data ->
   Shared`. Presentation does not depend on Data.
2. **Business state comes first:** state originates as business state in domain (a `StateManager`).
   Distinguish business, service and ephemeral state.
3. **DI keeps its deps private:** a public container implements the `XxxScope` interface, the deps
   stay hidden, a child depends on a parent interface. The mechanics are `yx-scope-fundamentals`.
4. **State changes only inside its handler:** the operation queue is what prevents race conditions.
   The mechanics are `yx-state-fundamentals`.
5. **Navigation starts from business logic:** it is a tree mutation, not a screen call, and it needs
   no `BuildContext`. The mechanics are `yx-navigation-fundamentals`.
6. **Repositories stay isolated, managers orchestrate:** a Repository does not depend on a
   Repository; a StateManager does not depend on a StateManager or an Interactor; logic that spans
   several state managers goes through an Interactor.
7. **No Flutter in Domain or in a ViewModel:** pure Dart (the exceptions in Domain are
   `NavigationInteractor` and platform channels). Do not register a ViewModel in DI.

## References index - topic to file

**Reading budget: at most 2 files per answer.** If you do not know where to start, read
`references/architecture/overview.md`.

| Topic | File |
|---|---|
| Layers, entities, roles, folder structure | `references/architecture/overview.md` |
| Easy/Medium/Hard boundaries, state mapping, StateProvider | `references/architecture/data_domain.md` |
| Recipe for a new feature, antipattern catalog | `references/architecture/recipes.md` |
| The ViewModel contract, the view object, who creates and disposes it | `references/view_model/overview.md` |
| ViewModel recipes, a complex screen, the emit filters | `references/view_model/recipes.md` |
| Feature facade: InputDeps/OutputDeps, the simple case | `references/feature_facade/overview.md` |

## Procedures

Three larger jobs have a procedure of their own. Each is also a slash command, but the procedure is
what does the work - follow it when the user asks for the same thing in prose.

| The user asks to | Procedure | Command |
|---|---|---|
| review code against the canon | `references/procedures/review.md` | `/yx-architecture:yx-review` |
| lay out a new feature | `references/procedures/new_feature.md` | `/yx-architecture:yx-new-feature` |
| design or audit an embeddable module | `references/procedures/feature_facade.md` | `/yx-architecture:yx-feature-facade` |

A procedure sets its own reading budget - the review reads every antipattern catalog that applies,
which is more than two files on purpose.

## Production vs simplified examples

In production code follow the production canon: interfaces in the generics, a parent interface,
hidden deps, `BaseScopeHolder` instead of `ScopeHolder`. The simplified getting-started examples (a
container in the generics, visible deps) exist only to explain the idea to a newcomer - do not copy
them into production.
