# yx_state: the Observer and the overrides

## The global StateManagerObserver

Monitors the lifecycle of every state manager: `onChange`, `onError`, `onHandleStart`, `onHandleDone`.

```dart
import 'package:flutter/foundation.dart';

class LoggingObserver extends StateManagerObserver {
  const LoggingObserver();
  @override
  void onChange(StateManagerBase<Object?> sm, Object? cur, Object? next, Object? id) {
    debugPrint('${sm.runtimeType}[$id]: $cur -> $next');
    super.onChange(sm, cur, next, id);
  }
  // onError, onHandleStart and onHandleDone work the same way
}

// register it once at startup
StateManagerOverrides.observer = const LoggingObserver();
```

`debugPrint` prints to the `flutter run` terminal and the IDE console. `log()` from `dart:developer` does not reach the terminal: it goes to the VM logging stream that DevTools shows. In pure Dart, use `print`.

## The local observer methods of a StateManager

A `StateManager` has the same lifecycle hooks as the global observer - override them **locally** (the signature drops the leading `sm` parameter):

```dart
class SomeStateManager extends StateManager<SomeState> {
  SomeStateManager(super.state);

  @override
  void onCreate() {
    super.onCreate();
    // the manager has been created
  }
  // the other local hooks: onChange, onError, onStart(identifier), onDone(identifier).
  // onHandleStart and onHandleDone exist only on the global StateManagerObserver.
}
```

The global observer monitors everything at once; the local methods let one manager react to its own lifecycle.

## identifier

```dart
Future<void> loadOrders() => handle(
  (emit) async { emit(state.copyWith(orders: await _repo.fetchOrders())); },
  identifier: 'loadOrders',  // shows up in the observer; can be any object, not just a string
);
```

## StateManagerOverrides - the global defaults

```dart
void main() {
  StateManagerOverrides.observer = const LoggingObserver();
  StateManagerOverrides.defaultHandlerFactory = concurrent;       // the default strategy
  StateManagerOverrides.defaultShouldEmit = (cur, next) => true;  // always emit
}
```
