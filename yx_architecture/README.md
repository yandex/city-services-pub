# yx_architecture

Agent Skills for the architecture canon behind [yx_scope](https://pub.dev/packages/yx_scope),
[yx_state](https://pub.dev/packages/yx_state) and
[yx_navigation](https://pub.dev/packages/yx_navigation).

This is not a Dart package and it contains no runtime code. It is four skills in the
[Agent Skills](https://agentskills.io/specification) format - one that an agent loads on its own and
three it runs on request - plus the reference documents they read.

## Why

The package docs answer "how does this API work". They do not answer "how do I assemble a feature
out of these three packages without creating structural problems later". This is the answer to the
second question:

- **The Data-Domain boundary rules** - Easy, Medium and Hard, with the trade-off of each stated
  explicitly, so the choice is deliberate rather than accidental.
- **The embeddable module contracts** - what a feature package exposes to its host and what it must
  never expose, with a nine-item review checklist.
- **Antipattern catalogs** - 12 entries for the layers and the shape of a feature, 12 for the
  ViewModel layer. An agent can check code against them instead of guessing. The catalogs for the
  packages themselves live in the package skills, see below.
- **The decisions that no API guides** - business versus service versus ephemeral state, when an
  Interactor is justified, what a ViewModel may and may not hold.

## Install

Start with the packages. Each of the three ships its own skill next to its code, so the agent learns
the API from the package it is actually using:

```
fvm dart run skills@ get --agent <claude|codex|cursor|copilot|cline|opencode|antigravity|generic>
```

That is the [Dart skills CLI](https://dart.dev/ai/package-skills)
([announcement](https://dart.dev/blog/skills-cli-1-0-bundle-and-distribute-ai-agent-skills-for-your-packages)),
version 1.0 or newer. It scans direct dependencies only, so `yx_scope`, `yx_state` and
`yx_navigation` have to be in `pubspec.yaml`, not just their `_flutter` counterparts.

Then add this canon on top:

| Agent | How |
|---|---|
| any | `npx skills add https://github.com/yandex/city-services-pub/tree/main/yx_architecture/skills/yx-architecture --agent <agent>` |
| any | copy the directories under `yx_architecture/skills/` into the skills directory of your agent |
| Claude Code | `/plugin marketplace add yandex/city-services-pub` then `/plugin install yx-architecture@city-services-pub` |
| Codex | `codex plugin marketplace add yandex/city-services-pub`, then pick the plugin in `/plugins` |
| Cursor | Dashboard, Plugins and MCPs, Import from Repo with the repository URL |

The plugin manifests are thin adapters over the same `skills/` directory: `.claude-plugin/`,
`.codex-plugin/` and `.cursor-plugin/`. Nothing in the skills themselves is specific to one agent.

## What is inside

### The canon skill

`yx-architecture` loads on its own when the conversation is about the shape of a feature in this
stack. Its references are grouped by topic under `skills/yx-architecture/references/`:

- `architecture/` - layers, entities, Data-Domain boundaries, the recipe for a new feature, the
  antipattern catalog
- `view_model/` - the ViewModel contract and recipes
- `feature_facade/` - contracts of an embeddable module
- `procedures/` - the three larger jobs: review, new feature, feature facade

The full topic-to-file index is in `SKILL.md`.

### The package skills

The API of each package is documented by the skill that ships inside it, so it is versioned with the
package and installed only when the project actually uses it:

| Skill | Ships in | Covers |
|---|---|---|
| `yx-scope-fundamentals` | `yx_scope` | containers, holders, deps, scope versus ScopeModule, async dependencies, 10 antipatterns |
| `yx-state-fundamentals` | `yx_state` | StateManager, handle and emit, strategies, cancellation, 10 antipatterns |
| `yx-navigation-fundamentals` | `yx_navigation` | the route tree, guards, deep links, Business Logic First, 9 antipatterns |

### The commands

Three skills next to the canon that you invoke explicitly; the model does not start them on its own.

| Command | What it does |
|---|---|
| `/yx-architecture:yx-review [path]` | reviews code against every applicable antipattern catalog and reports findings with fixes |
| `/yx-architecture:yx-new-feature <name> <description>` | answers the pre-flight checklist, then lays out the layers, the state and the route |
| `/yx-architecture:yx-feature-facade [path]` | designs the contracts of an embeddable module, or audits an existing one |

Each command is a thin wrapper: the work is described in
`skills/yx-architecture/references/procedures/`, and the command only pins the target. Asking for the
same thing in prose - "review this feature against the canon" - gets the same procedure, because the
canon skill lists it in its index. The commands exist for the explicit form and for the target
argument.

`review` uses the package catalogs when their skills are installed, and says which ones it could not
read when they are not.

### Nothing to copy into your project

The canon adds no runtime code and no base classes. A ViewModel is a plain Dart class that
`implements StateReadable<ViewObject>` - the two-member interface from `yx_state` - so it works with
`StateBuilder`, `StateListener` and `StateSelector` as they ship. See
`skills/yx-architecture/references/view_model/overview.md`.

## Testing the skills

```
python3 evals/run.py
```

Fifteen behaviour cases across all seven skills of the stack - the canon, its three commands and
the three package skills. The script builds a temporary bundle that contains
this plugin plus the three package skills and hands it to `claude plugin eval`, so a case is judged
with the same set of skills a real project has. Read `evals/README.md` before interpreting the
numbers: what matters is the delta between the run with the skills and the run without them.

## Ecosystem

| Package | Role |
|---|---|
| [yx_scope](https://pub.dev/packages/yx_scope) / [yx_scope_flutter](https://pub.dev/packages/yx_scope_flutter) | dependency injection without code generation |
| [yx_state](https://pub.dev/packages/yx_state) / [yx_state_flutter](https://pub.dev/packages/yx_state_flutter) | state management |
| [yx_navigation](https://pub.dev/packages/yx_navigation) / [yx_navigation_flutter](https://pub.dev/packages/yx_navigation_flutter) | declarative navigation over a route tree |

[![Pub - yx_scope](https://img.shields.io/pub/v/yx_scope)](https://pub.dev/packages/yx_scope)
[![Pub - yx_state](https://img.shields.io/pub/v/yx_state)](https://pub.dev/packages/yx_state)
[![Pub - yx_navigation](https://img.shields.io/pub/v/yx_navigation)](https://pub.dev/packages/yx_navigation)

This canon describes how the three are used together.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) - contributions are accepted under the Yandex CLA.

If your change touches a `SKILL.md`, and especially its `description`, please run the evals before
and after and attach both results to the pull request. The `description` is what drives triggering,
and a change there is easy to get wrong in a way that is not visible in a code review.

## License

MIT. See [LICENSE](LICENSE).
