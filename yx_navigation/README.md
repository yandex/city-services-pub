# yx_navigation packages

<div align="center">

<img src="https://github.com/yandex/city-services-pub/blob/main/yx_navigation/assets/logos/yx_navigation.webp?raw=true" width="200" alt="The yx_navigation package logo" />

</div>

Declarative navigation for large Flutter apps, built on the Navigator 2.0 API and a single
tree of route state ([`RouteNode`](packages/yx_navigation)) with explicit mutations.

The stack splits **navigation business logic** from **UI wiring**: reactive tree state,
feature isolation, guards, deeplinks, optional compatibility with legacy Navigator 1.0 flows,
and debug tooling — aimed at predictable behavior in modular codebases.

## Library components

The repo ships two packages (same split as [yx_scope](https://pub.dev/packages/yx_scope) /
[yx_state](https://pub.dev/packages/yx_state)):

| Package | Role |
| --- | --- |
| **[yx_navigation](packages/yx_navigation)** | Dart-only core: route tree, state manager, mutations, guards, serialization — usable without Flutter. |
| **[yx_navigation_flutter](packages/yx_navigation_flutter)** | Flutter integration: schemas, declarations, `Router` / delegate wiring, outlets, page factories, compatibility layer, debug tools. |

[![Pub — yx_navigation](https://img.shields.io/pub/v/yx_navigation)](https://pub.dev/packages/yx_navigation)
[![Pub — yx_navigation_flutter](https://img.shields.io/pub/v/yx_navigation_flutter)](https://pub.dev/packages/yx_navigation_flutter)

## Features

- **Two-tier API** — logic in pure Dart; optional Flutter layer for widgets and `Router` setup.
- **Declarative schemas** — `RouterSchema`: declarations, guards, and initial feature state;
  schemas can stand alone or nest inside a parent.
- **Business logic first** — `RouteNodeStateManager` / `NavigationController`: drive navigation
  from interactors without `BuildContext`.
- **Modularity** — nested features via `RouteDeclaration.scheme`, branch-scoped controllers via
  `NavigationController.node` (see the example app under
  `packages/yx_navigation_flutter/example`).
- **Guards** — control mutations (`next` / `redirect` / `cancel`) at declaration and schema level.
- **Declaration kinds** — builders, nested schemas, indexed stack / tabs.
- **Navigator 1.x compatibility** — interoperability for `push`, dialogs, bottom sheets, with
  documented limitations.

## Documentation

In-repo guides (start here):

- [Quick start](docs/quick_start.md) — walkthrough and API orientation
- [Architecture (short)](docs/quick_architecture.md)
- [Route declarations](docs/route_declarations.md)
- [Guards](docs/guards.md)
- [Compatibility architecture](docs/compatibility_architecture.md)

## Installation

Core (Dart-only navigation state, without Flutter UI):

```yaml
dependencies:
  yx_navigation: ^1.0.0
```

Flutter app:

```yaml
dependencies:
  yx_navigation_flutter: ^1.0.0
```

`yx_navigation_flutter` already depends on `yx_navigation`; add the core package only if you
need it without the Flutter layer.

## Ecosystem

yx_navigation is part of the **yx_architecture** family alongside
[yx_scope](https://pub.dev/packages/yx_scope) (DI) and
[yx_state](https://pub.dev/packages/yx_state) (state management).

## Agent skill

The `yx_navigation` package ships an [Agent Skill](https://agentskills.io/specification) called
`yx-navigation-fundamentals`: the rules an AI coding agent needs to write and review yx_navigation
code. It lives in `packages/yx_navigation/skills/`, so any project that has `yx_navigation` as a direct
dependency can install it:

```
fvm dart run skills@ get --agent <claude|codex|cursor|copilot|cline|opencode|antigravity|generic>
```

The command comes from the [Dart skills CLI](https://dart.dev/ai/package-skills)
([announcement](https://dart.dev/blog/skills-cli-1-0-bundle-and-distribute-ai-agent-skills-for-your-packages))
and needs version 1.0 or newer of that CLI. Only direct dependencies are scanned: an app that
depends on `yx_navigation_flutter` alone has to add `yx_navigation` to its `pubspec.yaml` as well to
receive the skill.

The architecture canon that ties yx_scope, yx_state and yx_navigation together is a separate skill,
[yx_architecture](https://github.com/yandex/city-services-pub/tree/main/yx_architecture).
