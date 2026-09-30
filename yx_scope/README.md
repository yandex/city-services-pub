# yx_scope packages

yx_scope is a compile-safe DI framework with advanced scoping capabilities.

## Library Components

The library group currently consists of:

- **[yx_scope](packages/yx_scope)**: The core implementation of the framework
- **[yx_scope_flutter](packages/yx_scope_flutter)**: An adapter library that allows embedding
  yx_scope containers into the widget tree
- **[yx_scope_linter](packages/yx_scope_linter)**: A set of custom lint rules that provide
  additional protection against errors when working with yx_scope

## Features

- Pure Dart
- DI-like (not static and not ServiceLocator)
- Compile-safe access to dependencies
- No code generation
- Flutter-friendly container management
- Declarative description of the dependency tree
- Non-reactive dependency tree
- Unambiguous behavior and lifecycle of dependencies in containers
- Ability to create scopes of any nesting level
- Compile-safe check for the existence of active scopes
- Support for asynchronous dependencies and their initialization
- Compile-safe protection against circular dependencies

## Agent skill

The `yx_scope` package ships an [Agent Skill](https://agentskills.io/specification) called
`yx-scope-fundamentals`: the rules an AI coding agent needs to write and review yx_scope code.
It lives in `packages/yx_scope/skills/`, so any project that has `yx_scope` as a direct dependency
can install it:

```
fvm dart run skills@ get --agent <claude|codex|cursor|copilot|cline|opencode|antigravity|generic>
```

The command comes from the [Dart skills CLI](https://dart.dev/ai/package-skills)
([announcement](https://dart.dev/blog/skills-cli-1-0-bundle-and-distribute-ai-agent-skills-for-your-packages))
and needs version 1.0 or newer of that CLI. Only direct dependencies are scanned: an app that
depends on `yx_scope_flutter` alone has to add `yx_scope` to its `pubspec.yaml` as well to receive
the skill.

The architecture canon that ties yx_scope, yx_state and yx_navigation together is a separate skill,
[yx_architecture](https://github.com/yandex/city-services-pub/tree/main/yx_architecture).
