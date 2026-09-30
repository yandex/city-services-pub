---
schema_version: "1.1"
name: cmd-feature-facade
description: The feature-facade command in audit mode walks the nine-item checklist, lists failures first and ends with a verdict.
tags: [command, feature-facade]
runs: 3
max_turns: 20
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill]
---

/yx-architecture:yx-feature-facade audit the package below

```dart
// lib/src/search_feature.dart
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

// lib/src/di/search_scope.dart
abstract interface class SearchScope {
  SearchStateManager get stateManager;
  SearchWidgetFactory get widgetFactory;
}

// lib/src/di/search_scope_holder.dart
class SearchScopeHolder extends ScopeHolder<SearchScopeContainer> {
  SearchScopeHolder({required SearchInputDeps inputDeps}) : _inputDeps = inputDeps;
  final SearchInputDeps _inputDeps;

  @override
  SearchScopeContainer createContainer() => SearchScopeContainer(inputDeps: _inputDeps);
}
```
