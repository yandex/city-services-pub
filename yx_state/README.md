# yx_state packages

State management library for Dart / Flutter.

## Library Components

The library group currently consists of:

- **[yx_state](packages/yx_state)**: The core library for state management
- **[yx_state_flutter](packages/yx_state_flutter)**: Flutter widgets for yx_state
- **[yx_state_transformers](packages/yx_state_transformers)**: Transformers for yx_state

## Agent skill

The `yx_state` package ships an [Agent Skill](https://agentskills.io/specification) called
`yx-state-fundamentals`: the rules an AI coding agent needs to write and review yx_state code.
It lives in `packages/yx_state/skills/`, so any project that has `yx_state` as a direct dependency
can install it:

```
fvm dart run skills@ get --agent <claude|codex|cursor|copilot|cline|opencode|antigravity|generic>
```

The command comes from the [Dart skills CLI](https://dart.dev/ai/package-skills)
([announcement](https://dart.dev/blog/skills-cli-1-0-bundle-and-distribute-ai-agent-skills-for-your-packages))
and needs version 1.0 or newer of that CLI. Only direct dependencies are scanned: an app that
depends on `yx_state_flutter` alone has to add `yx_state` to its `pubspec.yaml` as well to receive the skill.

The architecture canon that ties yx_scope, yx_state and yx_navigation together is a separate skill,
[yx_architecture](https://github.com/yandex/city-services-pub/tree/main/yx_architecture).
