import 'dart:async';

import 'package:test/test.dart';
import 'package:yx_scope/yx_scope.dart';

import 'utils/test_logger.dart';
import 'utils/utils.dart';

void main() {
  setUp(() {
    ScopeObservatory.logger = const TestLogger();
  });

  test('create and dispose scope works', () async {
    final holder = _TestScopeHolder();
    expect(holder.scope, isNull);

    await holder.create();
    expect(holder.scope, isNotNull);

    final scope = holder.scope;
    expect(ScopeContainerTestUtils.getDepCount(scope!), 1);
    await holder.drop();
    expect(ScopeContainerTestUtils.getDepCount(scope), 0);
    expect(holder.scope, isNull);
  });

  test('second initialization call fails with an exception', () async {
    final holder = _TestScopeHolder();
    expect(holder.scope, isNull);

    await holder.create();
    await expectThrown<ScopeException>(() async => holder.create());
  });

  test('unawaited second initialization call fails with an exception',
      () async {
    final holder = _TestScopeHolder();
    expect(holder.scope, isNull);

    // ignore: unawaited_futures
    holder.create();
    await expectThrown<ScopeException>(() async => holder.create());
  });

  test(
      'sync drop call during initialization waits until fully initialized and then drops',
      () async {
    final depOverride = _TestAsyncDep();
    final holder = _TestScopeHolder(asyncDepOverride: depOverride);
    expect(holder.scope, isNull);

    // ignore: unawaited_futures
    holder.create();
    await holder.drop();
    expect(depOverride._initialized, isFalse);
    expect(holder.scope, isNull);
  });

  test(
      'sync create call during dispose waits until fully disposed and then init',
      () async {
    final depOverride = _TestAsyncDep();
    final holder = _TestScopeHolder(asyncDepOverride: depOverride);
    expect(holder.scope, isNull);

    await holder.create();
    // ignore: unawaited_futures
    holder.drop();
    await holder.create();
    expect(depOverride._initialized, isTrue);
    expect(holder.scope, isNotNull);
  });

  test(
      'second unawaited call for create after unawaited drop throws an exception',
      () async {
    final depOverride = _TestAsyncDep();
    final holder = _TestScopeHolder(asyncDepOverride: depOverride);
    expect(holder.scope, isNull);

    await holder.create();
    // ignore: unawaited_futures
    holder.drop();
    // ignore: unawaited_futures
    holder.create();
    // ignore: unawaited_futures
    expectThrown<ScopeException>(() async => await holder.create());
  });

  test(
      'second unawaited call for drop after unawaited create throws an exception',
      () async {
    final depOverride = _TestAsyncDep();
    final holder = _TestScopeHolder(asyncDepOverride: depOverride);
    expect(holder.scope, isNull);

    await holder.create();
    // ignore: unawaited_futures
    await holder.drop();
    // ignore: unawaited_futures
    holder.create();
    // ignore: unawaited_futures
    holder.drop();
    expectThrown<ScopeException>(() async => await holder.drop());
  });

  test('sync create call after drop throw an assertion', () async {
    final depOverride = _TestAsyncDep();
    final holder = _TestScopeHolder(asyncDepOverride: depOverride);
    expect(holder.scope, isNull);

    await holder.create();
    // ignore: unawaited_futures
    holder.drop();
    await holder.create();
    expect(holder.scope, isNotNull);
    expect(holder.scope?.myAsyncDep.get._initialized, isTrue);
  });

  test('sync second drop call fails with an assertion', () async {
    final depOverride = _TestAsyncDep();
    final holder = _TestScopeHolder(asyncDepOverride: depOverride);
    expect(holder.scope, isNull);

    await holder.create();
    // ignore: unawaited_futures
    holder.drop();
    await expectAssertion(() async => holder.drop());
  });

  test('handling exception during init and dispose of async deps', () async {
    final testAsyncDep = _TestAsyncDep();
    final brokenInitAsyncDep = _BrokenInitAsyncDep();
    final brokenDisposeAsyncDep = _BrokenDisposeAsyncDep();
    final holder = _BrokenAsyncDepScopeHolder(
      asyncDepOverride: testAsyncDep,
      brokenInitAsyncDepOverride: brokenInitAsyncDep,
      brokenDisposeAsyncDepOverride: brokenDisposeAsyncDep,
    );

    try {
      await holder.create();
      fail('Must be an exception');
    } on BrokenInitException catch (_) {
      expect(testAsyncDep._initialized, isFalse);
      expect(brokenInitAsyncDep._disposed, isFalse);
      expect(brokenDisposeAsyncDep._initialized, isTrue);
    }

    expect(holder.scope, isNull);
  });

  test(
      'ScopeHolder creates different instances '
      'with different deps each new time', () async {
    final holder = _TestScopeHolder();
    expect(holder.scope, isNull);

    _TestScopeContainer? lastScope;
    var scopeCounter = 0;
    var noScopeCounter = 0;
    final completer = Completer<void>();
    final removeListener = holder.listen((scope) {
      if (scope != null) {
        expect(lastScope, isNot(scope));
        lastScope = scope;
        scopeCounter++;
      } else {
        noScopeCounter++;
      }
      if (scopeCounter + noScopeCounter == 6) {
        completer.complete();
      }
    });

    await holder.create();

    final scope1 = holder.scope;
    final dep1 = holder.scope?.myAsyncDep.get;
    expect(scope1, isNotNull);
    expect(dep1, isNotNull);

    await holder.drop();

    expect(holder.scope, isNull);

    await holder.create();

    final scope2 = holder.scope;
    final dep2 = holder.scope?.myAsyncDep.get;
    expect(scope2, isNotNull);
    expect(dep2, isNotNull);

    expect(scope1, isNot(scope2));
    expect(dep1, isNot(dep2));

    await holder.drop();

    await holder.create();

    await holder.drop();

    await completer.future;

    expect(scopeCounter, 3);
    expect(noScopeCounter, 3);

    removeListener();
  });

  test('assertion when dep is called after scope is disposed', () async {
    final holder = _TestScopeHolder();
    expect(holder.scope, isNull);

    await holder.create();
    final scope = holder.scope!;

    await holder.drop();
    await expectAssertion(() => scope.myAsyncDep.get);
  });

  test('exception when cached dep is called after scope is disposed', () async {
    final holder = _TestScopeHolder();
    expect(holder.scope, isNull);

    await holder.create();
    final scope = holder.scope!;
    final dep = scope.syncDep;

    await holder.drop();

    await expectThrown<ScopeException>(() => dep.get);
  });
}

class _TestScopeContainer extends ScopeContainer {
  final _TestAsyncDep? asyncDepOverride;

  _TestScopeContainer({this.asyncDepOverride});

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {myAsyncDep}
      ];

  late final myAsyncDep = asyncDep(() => asyncDepOverride ?? _TestAsyncDep());

  late final syncDep = dep(() => _SyncDep());
}

class _TestScopeHolder extends ScopeHolder<_TestScopeContainer> {
  final _TestAsyncDep? asyncDepOverride;

  _TestScopeHolder({this.asyncDepOverride});

  @override
  _TestScopeContainer createContainer() =>
      _TestScopeContainer(asyncDepOverride: asyncDepOverride);
}

class _SyncDep {}

class _TestAsyncDep implements AsyncLifecycle {
  var _initialized = false;

  @override
  Future<void> init() async {
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}

class _BrokenAsyncDepScopeContainer extends ScopeContainer {
  final _TestAsyncDep? asyncDepOverride;
  final _BrokenInitAsyncDep? brokenInitAsyncDepOverride;
  final _BrokenDisposeAsyncDep? brokenDisposeAsyncDepOverride;

  _BrokenAsyncDepScopeContainer({
    this.asyncDepOverride,
    this.brokenInitAsyncDepOverride,
    this.brokenDisposeAsyncDepOverride,
  });

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {testDep},
        {brokenDisposeDep},
        {brokenInitDep},
      ];

  late final testDep = asyncDep(() => asyncDepOverride ?? _TestAsyncDep());

  late final brokenInitDep =
      asyncDep(() => brokenInitAsyncDepOverride ?? _BrokenInitAsyncDep());

  late final brokenDisposeDep =
      asyncDep(() => brokenDisposeAsyncDepOverride ?? _BrokenDisposeAsyncDep());
}

class _BrokenAsyncDepScopeHolder
    extends ScopeHolder<_BrokenAsyncDepScopeContainer> {
  final _TestAsyncDep? asyncDepOverride;
  final _BrokenInitAsyncDep? brokenInitAsyncDepOverride;
  final _BrokenDisposeAsyncDep? brokenDisposeAsyncDepOverride;

  _BrokenAsyncDepScopeHolder({
    this.asyncDepOverride,
    this.brokenInitAsyncDepOverride,
    this.brokenDisposeAsyncDepOverride,
  });

  @override
  _BrokenAsyncDepScopeContainer createContainer() =>
      _BrokenAsyncDepScopeContainer(
        asyncDepOverride: asyncDepOverride,
        brokenInitAsyncDepOverride: brokenInitAsyncDepOverride,
        brokenDisposeAsyncDepOverride: brokenDisposeAsyncDepOverride,
      );
}

class _BrokenInitAsyncDep implements AsyncLifecycle {
  var _disposed = false;

  @override
  Future<void> init() async {
    throw BrokenInitException();
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }
}

class _BrokenDisposeAsyncDep implements AsyncLifecycle {
  var _initialized = false;

  @override
  Future<void> init() async {
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    throw Exception('broken dispose');
  }
}

class BrokenInitException implements Exception {}
