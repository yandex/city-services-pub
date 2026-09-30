---
schema_version: "1.1"
name: feature-facade-review
description: A facade that leaks past OutputDeps has to be caught, and no internal package names may appear in the answer.
tags: [feature_facade, review]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

Review this feature facade for me.

```dart
class SearchFeature implements SearchWidgetFactory {
  SearchFeature({required SearchInputDeps inputDeps})
      : _scopeHolder = SearchScopeHolder(inputDeps: inputDeps);

  final SearchScopeHolder _scopeHolder;

  SearchScopeHolder get scopeHolder => _scopeHolder;

  Future<void> init() => _scopeHolder.create();
  Future<void> dispose() => _scopeHolder.drop();

  @override
  Widget buildScreen() => SearchScreen(scope: _scopeHolder.scope!);
}

abstract interface class SearchScope {
  SearchStateManager get stateManager;
  SearchWidgetFactory get widgetFactory;
}
```
