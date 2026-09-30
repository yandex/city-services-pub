---
name: yx-navigation-fundamentals
description: >
  Apply the yx_navigation rules when working with Dart or Flutter code that uses the yx_navigation routing package. Trigger in any of these cases: (1) the user names yx_navigation, RouteNode, RouteNodeStateManager, NavigationController, RouterSchema, RouteDeclaration, RouteBuilder, YxRoute, RouteNodeGuard or YxRouterConfig; (2) the code imports package:yx_navigation or package:yx_navigation_flutter; (3) the user asks how to navigate from business logic without a BuildContext, how to guard a route, or how to isolate the navigation of a feature in an app built on this package.
  Do NOT apply to general Flutter navigation questions about Navigator, go_router or auto_route when no yx_navigation code is involved.
license: MIT
---

# yx_navigation: navigation as a route tree

The whole navigation state is one `RouteNode` tree. Every `push` and `pop` is a mutation of that
tree, which is why navigation can start from business logic and does not need a `BuildContext`.

## Principles (cheat sheet)

Details are in the references below; read one or two files, not all seven.

1. **There is no "just open a screen".** Every operation is a tree mutation, and the tree is the
   single source of truth for what is on screen.
2. **Business Logic First.** Logic navigates through a `NavigationController` it was given, with no
   `BuildContext` involved. `push` and `pop` return `void` and are not awaited.
3. **Route ids are descriptive and unique.** Collisions are not resolved for you, so prefix them per
   feature, for example `profile-home`.
4. **Guards are policy, not orchestration.** A guard decides whether a node may appear; anything that
   coordinates several steps belongs in the logic layer of the application.
5. **A feature can own its scheme.** `RouteDeclaration.scheme` isolates the internal routes of a
   feature from its host; plain nesting that needs no isolation is `RouteBuilder.outlet`.
6. **Serialization has to be explicit.** A route that takes part in deep links declares how its
   arguments are written and read.

## References index - topic to file

| Topic | File |
|---|---|
| The RouteNode tree, entities, declarations, RouteBuilder | `references/overview.md` |
| Guards and AuthGuard | `references/guards.md` |
| Business Logic First, the page factory | `references/blf.md` |
| Serialization and deep links | `references/deeplinks.md` |
| Feature isolation through a scheme, mutating inactive branches | `references/isolation.md` |
| Interop with Navigator 1.0, the debug panel | `references/compatibility.md` |
| Scheme recipes: minimal, tabs, a nested feature; nine antipatterns | `references/recipes.md` |

## Beyond this skill

This skill covers the package itself. Where navigation logic belongs among the layers of an
application, and how a feature exposes its scheme to a host, are questions about the architecture
around the package - they are answered by the `yx-architecture` skill at
https://github.com/yandex/city-services-pub/tree/main/yx_architecture.

The DI and state packages of the same stack ship their own skills, `yx-scope-fundamentals` and
`yx-state-fundamentals`. Install them with `fvm dart run skills@ get --agent <your agent>` when the
project depends on those packages.
