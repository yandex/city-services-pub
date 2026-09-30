# yx_state

<div align="center">

<img src="https://github.com/yandex/city-services-pub/blob/main/yx_state/assets/logos/yx_state.webp?raw=true" width="200" alt="The yx_state package logo" />

**A state management library for Dart/Flutter applications.**

[![Pub Version](https://img.shields.io/pub/v/yx_state)](https://pub.dev/packages/yx_state)

</div>

---

## 📦 Installation

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  yx_state: <version>
```

## 🚀 Quick Start

### Basic Counter Example

```dart
import 'package:yx_state/yx_state.dart';

// Define your state
class CounterState {
    final int count;

    const CounterState(this.count);

    @override
    bool operator ==(Object other) {
        if (identical(this, other)) return true;
        return other is CounterState && other.count == count;
    }

    @override
    int get hashCode => count.hashCode;
}

// Create a state manager
class CounterManager extends StateManager<CounterState> {
    CounterManager() : super(const CounterState(0));

    void increment() => handle((emit) async {
        emit(CounterState(state.count + 1));
      });

    void decrement() => handle((emit) async {
        emit(CounterState(state.count - 1));
      });
}

// Use the state manager
void main() {
    final counter = CounterManager();

    // Listen to state changes
    counter.stream.listen((state) {
        print('Count: ${state.count}');
    });

    // Trigger state changes
    counter.increment(); // Output: Count: 1
    counter.increment(); // Output: Count: 2
    counter.decrement(); // Output: Count: 1

    // Clean up resources when done
    counter.close();
}
```

## 🔧 Features

### State Observers

Monitor state changes for debugging or analytics:

```dart
class MyCustomObserver extends StateManagerObserver {
  const MyCustomObserver();

  @override
  void onChange(
    StateManagerBase<Object?> stateManager,
    Object? currentState,
    Object? nextState,
    Object? identifier,
  ) {
    print(
      'State changed from $currentState to $nextState with '
      'identifier: $identifier',
    );
    super.onChange(stateManager, currentState, nextState, identifier);
  }
}

void main() {
  // Set the observer globally
  StateManagerOverrides.observer = const MyCustomObserver();
}
```

### Global Overrides

Customize behavior globally:

```dart
void main() {
    // Set the shouldEmit globally
    StateManagerOverrides.defaultShouldEmit = (current, next) => true;
}
```

### Error Handling

Comprehensive error handling with built-in support:

```dart
class ErrorHandlingStateManager extends StateManager<MyState> {
  ErrorHandlingStateManager() : super(MyState.initial());

  Future<void> performOperation() => handle((emit) async {
    try {
      ...
      // Risky operation
      final result = await someApiCall();
      emit(MyState.success(data: result));
    } catch (error, stackTrace) {
      // Report error through the state manager
      addError(error, stackTrace);
      ...
    }
  });
}
```

## Agent skill

This package ships an [Agent Skill](https://agentskills.io/specification) called
`yx-state-fundamentals`: the rules an AI coding agent needs to write and review yx_state code.
It lives in `skills/` inside the package, so any project that has `yx_state` as a direct dependency
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
