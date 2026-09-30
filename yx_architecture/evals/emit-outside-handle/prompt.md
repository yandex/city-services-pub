---
schema_version: "1.1"
name: emit-outside-handle
description: An emit fired from a timer callback escapes the handle and is silently dropped in production.
tags: [yx_state, bug]
runs: 3
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
---

This state manager sometimes does not update the state at all, and in debug builds I occasionally get an assertion. What is wrong with it?

```dart
class PollingStateManager extends StateManager<PollingState> {
  PollingStateManager(super.state);

  Future<void> startPolling() => handle((emit) async {
    emit(state.copyWith(isPolling: true));
    Timer.periodic(const Duration(seconds: 5), (_) {
      emit(state.copyWith(tick: state.tick + 1));
    });
  });
}
```
