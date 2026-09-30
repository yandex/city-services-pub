# City Services Flutter™ Libraries

This repository contains a collection of Flutter™ libraries developed by Yandex City Services. These libraries provide reusable components and utilities for building Flutter mobile applications.

## Usage

Each library contains its own documentation and usage examples. Please refer to individual directories for specific implementation details.

## Agent skills

Three of the libraries ship an [Agent Skill](https://agentskills.io/specification) inside the
package, so an
AI coding agent learns the API from the package the project actually depends on. Install them with
the [Dart skills CLI](https://dart.dev/ai/package-skills):

```
fvm dart run skills@ get --agent <claude|codex|cursor|copilot|cline|opencode|antigravity|generic>
```

| Skill | Ships in |
|---|---|
| `yx-scope-fundamentals` | [yx_scope](yx_scope) |
| `yx-state-fundamentals` | [yx_state](yx_state) |
| `yx-navigation-fundamentals` | [yx_navigation](yx_navigation) |

On top of them, [yx_architecture](yx_architecture) holds the canon of using the three together -
layers, the Data-Domain boundary, the ViewModel contract, embeddable feature modules - plus three
procedures for reviewing and planning a feature, each also available as a slash command. It is not a Dart package and ships no runtime code;
copy its skills into your agent, or install it as a plugin:

```
/plugin marketplace add yandex/city-services-pub       # Claude Code
codex plugin marketplace add yandex/city-services-pub  # Codex
```

## **Contributing**

We welcome contributions from the community. Please read our contributing guidelines before submitting pull requests.

## **License**

Please check individual package licenses for specific terms and conditions.

---

**Disclaimer:** Flutter and the related logo are trademarks of Google LLC. We are not endorsed by or affiliated with Google LLC.