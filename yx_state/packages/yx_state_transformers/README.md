# yx_state_transformers

Custom task transformers for [yx_state](https://pub.dev/packages/yx_state).

## Concurrency Strategies

yx_state_transformers provides several concurrency strategies for handling tasks:

1. **Sequential** - Process tasks one after another in order:

```dart
class CounterManager extends StateManager<CounterState> {
    CounterManager()
      : super(
          const CounterState(0),
          handler: sequential(),
      );
}
```

2. **Concurrent** - Process tasks in parallel:

```dart
class CounterManager extends StateManager<CounterState> {
    CounterManager()
      : super(
          const CounterState(0),
          handler: concurrent(),
      );
}
```

3. **Droppable** - Ignore new tasks while processing:

```dart
class CounterManager extends StateManager<CounterState> {
    CounterManager()
      : super(
          const CounterState(0),
          handler: droppable(),
      );
}
```

4. **Restartable** - Cancel current task when a new one comes in:

```dart
class CounterManager extends StateManager<CounterState> {
    CounterManager()
      : super(
          const CounterState(0),
          handler: restartable(),
      );
}
```
