---
name: yx-state-fundamentals
description: >
  Apply the yx_state rules to Dart or Flutter code that uses the yx_state package. Trigger in any of these cases: (1) the user names yx_state, StateReadable, StateManagerObserver, StateManagerOverrides, or a StateBuilder, StateListener, StateConsumer or StateSelector widget; (2) the code imports package:yx_state or package:yx_state_flutter; (3) a state update was lost, duplicated or reordered in code built on it.
  Trigger on StateManager, handle, emit or a strategy name (sequential, restartable, droppable, concurrent) only where they appear as yx_state code - a class extending StateManager, a handle((emit) async {...}) call, a handler: argument - or next to yx_state itself. As bare words about another package they are NOT a trigger: bloc_concurrency uses the same four strategy names, and handle and emit are ordinary Dart.
  Do NOT apply to general Flutter state management questions about BLoC, Provider, Riverpod or setState when no yx_state code is involved.
license: MIT
---

# yx_state: one state object behind an operation queue

A `StateManager` owns one state object, and every write to it goes through `handle`. The strategy
you pick decides what happens when a second call arrives while the first is still running: queue it,
drop it, cancel the previous one, or run both. Only the default, sequential, guarantees order.

## Principles (cheat sheet)

Details are in the references below; read the one that matches the question, not all of them.

1. **All logic lives inside `handle((emit) async {...})`.** That is what the operation queue governs.
2. **`emit` is only valid inside its own handler.** A call that escapes it is a race that debug
   catches and release does not - see `references/handle.md` for what exactly happens and why.
3. **Pick the strategy deliberately.** Sequential queues the work, restartable cancels the previous
   run, droppable ignores the new call while one is running, concurrent runs everything at once.
4. **Cancellation is cooperative.** A cancelled handler keeps running until it checks `emit.isDone`,
   so long operations have to check it.
5. **`close()` is mandatory**, and it belongs to whoever owns the manager.
6. **What goes outward is `StateReadable<T>`**, the read-only interface.

## References index - topic to file

| Topic | File |
|---|---|
| Concepts, kinds of state, strategies | `references/overview.md` |
| handle and emit rules, cancellation, `close()` | `references/handle.md` |
| the Observer, the local hooks, `StateManagerOverrides` | `references/observer.md` |
| `StateBuilder`, `StateListener`, `StateSelector`, wiring to a DI container, ten antipatterns | `references/flutter_recipes.md` |

## Beyond this skill

This skill covers the package itself. Which state belongs in a manager at all, how managers are
coordinated when a feature needs several of them, and where a ViewModel fits are questions about the
architecture around the package - they are answered by the `yx-architecture` skill at
https://github.com/yandex/city-services-pub/tree/main/yx_architecture.

The DI and navigation packages of the same stack ship their own skills, `yx-scope-fundamentals` and
`yx-navigation-fundamentals`. Install them with `fvm dart run skills@ get --agent <your agent>` when
the project depends on those packages.
