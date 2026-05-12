# Unit-test standard for `yx_navigation`

This document is the source of truth for how unit tests are written in this
package. The companion package
[`yx_navigation_flutter`](https://pub.dev/packages/yx_navigation_flutter)
ships with an equivalent document so that contributors can move between the
two without relearning conventions — the two files are kept in sync manually.

> **Scope**: `test/**` in this package.
> **Applies to**: every new or changed test file.

---

## 1. Structure

1. **AAA layout.** Every test is split by `// arrange` / `// act` /
   `// assert` comments. When the arrange section is large, extract it into a
   `setUp` or helper. Combined markers are allowed (`// arrange/act`,
   `// act/assert`) when phases physically collapse into a single expression.
   One-liner tests without markers are fine too.
2. **One test = one scenario.** It is forbidden to chain several
   act/assert phases inside a single `test(...)` via `reset(mock)` /
   `clearInteractions(mock)`. Split them.
3. **Unit vs integration.** `*_test.dart` files in the package `test/`
   directory are treated as solitary unit tests. Wider scenarios with a real
   `MaterialApp.router` / real `StateManager` / real router live in
   `test/integration/` (created once more than one such test appears).

## 2. Isolation (solitary)

4. **Mocks do not delegate to real implementations.** Instead of
   `when(...).thenAnswer((inv) => realImpl.call(inv.positionalArguments[0]))`
   — use `thenReturn(fixedValue)`.
5. **Do not test SDK contracts.** `MapEquality`, `DeepCollectionEquality`,
   `Uri.encodeComponent`, etc. are either covered in their own repositories or
   exercised implicitly through our code.

## 3. Asynchrony

6. **Forbidden**: `await Future<void>.delayed(Duration.zero)` and any real
   delays. To drain microtasks / timers — use
   `testAsync(description, (fa) { ...; fa.flushMicrotasks(); })` from
   `test/helpers/async.dart`.
7. `await Future<void>.delayed(<non-zero>)` is replaced with
   `fa.elapse(duration)`.
8. `StreamController.stream` subscribers are drained with
   `fa.flushMicrotasks()`. **All controllers must be created inside the
   `testAsync` body** — not in `setUpAll` — otherwise they escape into the
   parent zone and hang while waiting for emissions.
8a. **Forbidden: `expectLater` / `emitsInOrder` / `emits` / `emitsDone`
    inside `testAsync`.** The `testAsync` body is synchronous — you cannot
    return or `await` the future from `expectLater`, the matcher resolves
    asynchronously, and failures go to the fake zone's uncaught-error handler
    which **does not** fail the test. On top of that, `emitsInOrder([...])`
    is a prefix match: `emitsInOrder([])` passes on any stream — meaning a
    reviewer can silently delete the expected value and the test stays green.
    Canonical pattern:
    ```dart
    final emitted = <T>[];
    final sub = source.stream.listen(emitted.add);
    addTearDown(sub.cancel);
    // ... act + fa.flushMicrotasks() ...
    expect(emitted, equals(<T>[expected]));
    ```
    For `emitsDone` — `listen(null, onDone: () => actualDone = true)` plus a
    synchronous `expect(actualDone, isTrue)`.

## 4. Assertions

9. **Exact counts.** Use `equals(N)` instead of `greaterThan(0)` /
   `greaterThanOrEqualTo(1)` / `isNotEmpty` when `N` is known from the
   contract.
10. **Exact values.** Use `equals(expected)` instead of `isNotNull` when the
    test should pin down what exactly was written.
11. **Round-trip is not a one-liner.** Supplement `decode(encode(x)) == x`
    with `expect(encoded, isNotEmpty)` + `expect(encoded, isNot(equals(x)))`
    so that a symmetric encode/decode bug does not pass silently.
12. **Comparator tests** use `lessThan(0)` / `greaterThan(0)` / `equals(0)` —
    this is exactly the `Comparable<T>` contract. Do **not** use
    `equals(-1)` / `equals(1)`: they depend on the implementation.

## 5. What we don't test

13. **Defaults of const classes** (e.g. `expect(Config().field, isNull)` for
    a const field with a default in the constructor) — this duplicates the
    declaration; the test protects nothing.
14. **Empty no-op hooks** via `returnsNormally` — an empty method cannot
    throw by definition.
15. **Type-system guarantees** — `final` fields are immutable, enums contain
    their own values, and so on.

## 6. Infrastructure

16. **Shared factories** live in `test/helpers/factories.dart` (`makeNode`,
    `makeImmutableNode`, `makeMutableNode`, `makeRoute`). Local builders in
    test files are **forbidden**.
17. **Shared fallbacks** live in `test/helpers/fallbacks.dart`, wired up via
    `setUpAll(registerFallbacks)`.
18. **`testAsync` helper** lives in `test/helpers/async.dart` (a wrapper for
    `test(description, () => fakeAsync(body))`).
19. **Route constants** (if reused) live in `test/helpers/routes.dart`.
    Local `_Routes` in a single file are allowed only when the scenario is
    unique to that file.

## 7. Scenario documentation

20. For complex scenarios (nested routes, navigation trees) — use an ASCII
    `Before → Expected` diagram in a doc comment above the test.

## 8. Coverage

21. **Coverage gate: 80%+** at the unit level for each package. Verified
    locally via `flutter test --coverage`.

## 9. Lifecycle hygiene

22. **Every disposable resource is registered under `addTearDown`
    immediately** — `StateManager`, `YxRouteInformationProvider`,
    `YxRouterDelegate`, `YxRouterConfig`, `GuardSync`, any `ChangeNotifier`
    / `StreamController`. An explicit `close()` / `dispose()` at the end of
    a test is forbidden — it is skipped on exceptions and leaks resources.
    Canonical pattern:
    ```dart
    final config = schema.build();
    addTearDown(config.dispose);
    ```
23. **No file-level / group-level resources outside `setUp`.** Shared state
    via `final foo = Foo()` at file scope leaks between tests and breaks
    under parallel runs. Everything goes into `setUp` / `tearDown` (or
    `addTearDown` inside the test body).

## 10. Matchers

24. **Typed matchers instead of `throwsA(isA<X>())`**: `throwsStateError`,
    `throwsArgumentError`, `throwsFormatException`, `throwsRangeError`,
    `throwsUnsupportedError`, `throwsUnimplementedError`. Shorter and reads
    as intent. `throwsAssertionError` is unavailable in this package (it
    lives in `package:flutter_test`, while `yx_navigation` is pure Dart) —
    for assertions use `throwsA(isA<AssertionError>())`.

---

## Quick reference for LLM agents

If you are asked to write or fix a test in `yx_navigation*`, walk the
checklist top to bottom:

1. Does the file have `setUpAll(registerFallbacks)`? If not — add it.
2. Creating a `StateManager` / `RouterConfig` / `Notifier` / `Controller` /
   `StreamController` / `GuardSync`? → immediately
   `addTearDown(resource.close / dispose)`.
3. Is there an `await Future.delayed(...)` inside the test? → rewrite as
   `testAsync((fa) { ... fa.flushMicrotasks() / fa.elapse(...) })`.
4. `throwsA(isA<XxxError>())`? → `throwsXxxError`.
5. `greaterThan(0)` / `isNotNull` where the number / value is
   deterministic? → `equals(N)` / `equals(expected)`.
6. Test body > 6 lines without `// arrange|act|assert`? → add them.
7. A single `test(...)` checking more than one entity (multiple mutate +
   multiple expect blocks)? → split into separate `test(...)`s.
8. New builder / mock / route constant? → search `test/helpers/*` first,
   and only add a new one if nothing fits.
