import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

typedef TestAsyncCallback = void Function(FakeAsync fa);

/// Wraps [test] with [fakeAsync] so the body runs inside a controllable
/// zone. Use instead of `test(..., () { fakeAsync(...) })` for consistency.
///
/// Always call [FakeAsync.flushMicrotasks] (or advance the fake clock via
/// [FakeAsync.elapse]) before asserting on async results — pending
/// microtasks and timers do NOT drain automatically when the body returns,
/// and `fakeAsync` will throw on exit only for *timers*, not for un-drained
/// microtasks.
///
/// **Do not use `expectLater` / `emits*` inside the body** — the returned
/// `Future` is never awaited (the body is synchronous), the matcher resolves
/// asynchronously, failures go to the fake zone's uncaught-error handler, and
/// the test still reports PASS. Additionally, `emitsInOrder([...])` is a
/// prefix match, so `emitsInOrder([])` passes trivially — meaning a reviewer
/// can remove the expected value entirely and the test keeps green.
///
/// Canonical pattern: collect emissions into a list via `listen` and assert
/// synchronously with `expect(list, equals([...]))`.
///
/// Example:
/// ```dart
/// testAsync('emits current state after push', (fa) {
///   final emitted = <RouteNode>[];
///   final sub = manager.stream.listen(emitted.add);
///   addTearDown(sub.cancel);
///
///   manager.push(route);
///   fa.flushMicrotasks();
///
///   expect(emitted, equals(<RouteNode>[expectedNode]));
/// });
/// ```
void testAsync(String description, TestAsyncCallback body) =>
    test(description, () => fakeAsync(body));
