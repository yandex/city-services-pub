import 'dart:async';

import 'package:test/test.dart';
import 'package:yx_scope/yx_scope.dart';

import 'utils/test_logger.dart';

void main() {
  setUp(() {
    ScopeObservatory.logger = const TestLogger();
  });

  test('success calls in correct order with correct params', () async {
    final listener = TestObserver();
    final holder = _TestScopeHolder(listener);

    await holder.create();

    holder.scope?.syncDep.get;

    await holder.drop();

    final events = listener._events;
    expect(events[0].name, 'onScopeStartInitialize');
    expect(events[0].scope.type, _TestScopeContainer);

    expect(events[1].name, 'onValueStartCreate');
    expect(events[1].scope.type, _TestScopeContainer);
    expect(events[1].dep?.valueType, _TestAsyncDep);
    expect(events[1].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[2].name, 'onValueCreated');
    expect(events[2].scope.type, _TestScopeContainer);
    expect(events[2].dep?.valueType, _TestAsyncDep);
    expect(events[2].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[2].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[3].name, 'onDepStartInitialize');
    expect(events[3].scope.type, _TestScopeContainer);
    expect(events[3].dep?.valueType, _TestAsyncDep);
    expect(events[3].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[3].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[4].name, 'onDepInitialized');
    expect(events[4].scope.type, _TestScopeContainer);
    expect(events[4].dep?.valueType, _TestAsyncDep);
    expect(events[4].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[4].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[5].name, 'onScopeInitialized');
    expect(events[5].scope.type, _TestScopeContainer);
    expect(events[5].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[6].name, 'onValueStartCreate');
    expect(events[6].scope.type, _TestScopeContainer);
    expect(events[6].dep?.valueType, _SyncDep);
    expect(events[6].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[7].name, 'onValueCreated');
    expect(events[7].scope.type, _TestScopeContainer);
    expect(events[7].dep?.valueType, _SyncDep);
    expect(events[7].dep?.depHashCode, events[6].dep?.depHashCode);
    expect(events[7].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[8].name, 'onScopeStartDispose');
    expect(events[8].scope.type, _TestScopeContainer);
    expect(events[8].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[9].name, 'onDepStartDispose');
    expect(events[9].scope.type, _TestScopeContainer);
    expect(events[9].dep?.valueType, _TestAsyncDep);
    expect(events[9].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[9].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[10].name, 'onDepDisposed');
    expect(events[10].scope.type, _TestScopeContainer);
    expect(events[10].dep?.valueType, _TestAsyncDep);
    expect(events[10].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[10].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[11].name, 'onValueCleared');
    expect(events[11].scope.type, _TestScopeContainer);
    expect(events[11].dep?.valueType, _SyncDep);
    expect(events[11].dep?.depHashCode, events[6].dep?.depHashCode);
    expect(events[11].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[12].name, 'onValueCleared');
    expect(events[12].scope.type, _TestScopeContainer);
    expect(events[12].dep?.valueType, _TestAsyncDep);
    expect(events[12].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[12].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[13].name, 'onScopeDisposed');
    expect(events[13].scope.type, _TestScopeContainer);
    expect(events[13].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events.length, 14);
  });

  test('init failure calls in correct order with correct params', () async {
    final listener = TestObserver();
    final holder = _BrokenAsyncDepScopeHolder(listener);

    try {
      await holder.create();
    } catch (e) {
      expect(e, isA<BrokenInitException>());
    }

    final events = listener._events;
    expect(events[0].name, 'onScopeStartInitialize');
    expect(events[0].scope.type, _BrokenAsyncDepScopeContainer);

    expect(events[1].name, 'onValueStartCreate');
    expect(events[1].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[1].dep?.valueType, _TestAsyncDep);
    expect(events[1].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[2].name, 'onValueCreated');
    expect(events[2].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[2].dep?.valueType, _TestAsyncDep);
    expect(events[2].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[2].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[3].name, 'onDepStartInitialize');
    expect(events[3].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[3].dep?.valueType, _TestAsyncDep);
    expect(events[3].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[3].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[4].name, 'onDepInitialized');
    expect(events[4].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[4].dep?.valueType, _TestAsyncDep);
    expect(events[4].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[4].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[5].name, 'onValueStartCreate');
    expect(events[5].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[5].dep?.valueType, _BrokenInitAsyncDep);
    expect(events[5].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[6].name, 'onValueCreated');
    expect(events[6].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[6].dep?.valueType, _BrokenInitAsyncDep);
    expect(events[6].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[6].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[7].name, 'onDepStartInitialize');
    expect(events[7].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[7].dep?.valueType, _BrokenInitAsyncDep);
    expect(events[7].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[7].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[8].name, 'onDepInitializeFailed');
    expect(events[8].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[8].dep?.valueType, _BrokenInitAsyncDep);
    expect(events[8].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[8].scope.scopeHashCode, events[0].scope.scopeHashCode);
    expect(events[8].exception, isA<BrokenInitException>());

    expect(events[9].name, 'onScopeInitializeFailed');
    expect(events[9].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[9].scope.scopeHashCode, events[0].scope.scopeHashCode);
    expect(events[9].exception, isA<BrokenInitException>());

    expect(events[10].name, 'onScopeStartDispose');
    expect(events[10].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[10].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[11].name, 'onDepStartDispose');
    expect(events[11].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[11].dep?.valueType, _TestAsyncDep);
    expect(events[11].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[11].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[12].name, 'onDepDisposed');
    expect(events[12].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[12].dep?.valueType, _TestAsyncDep);
    expect(events[12].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[12].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[13].name, 'onValueCleared');
    expect(events[13].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[13].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[13].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[14].name, 'onValueCleared');
    expect(events[14].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[14].dep?.valueType, _BrokenInitAsyncDep);
    expect(events[14].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[14].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[15].name, 'onValueCleared');
    expect(events[15].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[15].dep?.valueType, _TestAsyncDep);
    expect(events[15].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[15].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[16].name, 'onScopeDisposed');
    expect(events[16].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[16].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events.length, 17);
  });

  test('dispose calls in correct order with correct params', () async {
    final listener = TestObserver();
    final holder = _BrokenAsyncDepScopeHolder(listener, checkDispose: true);

    await holder.create();
    try {
      await holder.drop();
    } catch (_) {
      fail('Drop must complete anyway');
    }

    final events = listener._events;
    expect(events[0].name, 'onScopeStartInitialize');
    expect(events[0].scope.type, _BrokenAsyncDepScopeContainer);

    expect(events[1].name, 'onValueStartCreate');
    expect(events[1].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[1].dep?.valueType, _TestAsyncDep);
    expect(events[1].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[2].name, 'onValueCreated');
    expect(events[2].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[2].dep?.valueType, _TestAsyncDep);
    expect(events[2].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[2].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[3].name, 'onDepStartInitialize');
    expect(events[3].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[3].dep?.valueType, _TestAsyncDep);
    expect(events[3].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[3].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[4].name, 'onDepInitialized');
    expect(events[4].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[4].dep?.valueType, _TestAsyncDep);
    expect(events[4].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[4].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[5].name, 'onValueStartCreate');
    expect(events[5].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[5].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[5].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[6].name, 'onValueCreated');
    expect(events[6].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[6].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[6].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[6].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[7].name, 'onDepStartInitialize');
    expect(events[7].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[7].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[7].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[7].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[8].name, 'onDepInitialized');
    expect(events[8].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[8].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[8].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[8].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[9].name, 'onScopeInitialized');
    expect(events[9].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[9].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[10].name, 'onScopeStartDispose');
    expect(events[10].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[10].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[11].name, 'onDepStartDispose');
    expect(events[11].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[11].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[11].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[11].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[12].name, 'onDepDisposeFailed');
    expect(events[12].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[12].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[12].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[12].scope.scopeHashCode, events[0].scope.scopeHashCode);
    expect(events[12].exception, isA<BrokenDisposeException>());

    expect(events[13].name, 'onScopeDisposeDepFailed');
    expect(events[13].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[13].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[13].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[13].scope.scopeHashCode, events[0].scope.scopeHashCode);
    expect(events[13].exception, isA<BrokenDisposeException>());

    expect(events[14].name, 'onDepStartDispose');
    expect(events[14].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[14].dep?.valueType, _TestAsyncDep);
    expect(events[14].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[14].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[15].name, 'onDepDisposed');
    expect(events[15].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[15].dep?.valueType, _TestAsyncDep);
    expect(events[15].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[15].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[16].name, 'onValueCleared');
    expect(events[16].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[16].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[16].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[16].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[17].name, 'onValueCleared');
    expect(events[17].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[17].dep?.valueType, _TestAsyncDep);
    expect(events[17].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[17].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[18].name, 'onScopeDisposed');
    expect(events[18].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[18].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events.length, 19);
  });

  test('create failure calls in correct order with correct params', () async {
    final listener = TestObserver();
    final holder = _BrokenAsyncDepScopeHolder(listener, checkDispose: true);

    await holder.create();

    try {
      holder.scope?.brokenCreateDep.get;
      // should not produce any listener event
      holder.scope?.testAsyncDep.get;
    } catch (e) {
      expect(e, isA<BrokenCreateException>());
    }
    try {
      await holder.drop();
    } catch (_) {
      fail('Drop must complete anyway');
    }

    final events = listener._events;
    expect(events[0].name, 'onScopeStartInitialize');
    expect(events[0].scope.type, _BrokenAsyncDepScopeContainer);

    expect(events[1].name, 'onValueStartCreate');
    expect(events[1].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[1].dep?.valueType, _TestAsyncDep);
    expect(events[1].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[2].name, 'onValueCreated');
    expect(events[2].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[2].dep?.valueType, _TestAsyncDep);
    expect(events[2].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[2].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[3].name, 'onDepStartInitialize');
    expect(events[3].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[3].dep?.valueType, _TestAsyncDep);
    expect(events[3].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[3].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[4].name, 'onDepInitialized');
    expect(events[4].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[4].dep?.valueType, _TestAsyncDep);
    expect(events[4].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[4].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[5].name, 'onValueStartCreate');
    expect(events[5].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[5].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[5].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[6].name, 'onValueCreated');
    expect(events[6].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[6].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[6].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[6].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[7].name, 'onDepStartInitialize');
    expect(events[7].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[7].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[7].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[7].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[8].name, 'onDepInitialized');
    expect(events[8].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[8].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[8].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[8].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[9].name, 'onScopeInitialized');
    expect(events[9].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[9].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[10].name, 'onValueStartCreate');
    expect(events[10].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[10].dep?.valueType, NeverCreatedValue);
    expect(events[10].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[11].name, 'onValueCreateFailed');
    expect(events[11].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[11].dep?.valueType, NeverCreatedValue);
    expect(events[11].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[12].name, 'onScopeStartDispose');
    expect(events[12].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[12].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[13].name, 'onDepStartDispose');
    expect(events[13].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[13].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[13].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[13].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[14].name, 'onDepDisposeFailed');
    expect(events[14].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[14].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[14].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[14].scope.scopeHashCode, events[0].scope.scopeHashCode);
    expect(events[14].exception, isA<BrokenDisposeException>());

    expect(events[15].name, 'onScopeDisposeDepFailed');
    expect(events[15].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[15].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[15].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[15].scope.scopeHashCode, events[0].scope.scopeHashCode);
    expect(events[15].exception, isA<BrokenDisposeException>());

    expect(events[16].name, 'onDepStartDispose');
    expect(events[16].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[16].dep?.valueType, _TestAsyncDep);
    expect(events[16].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[16].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[17].name, 'onDepDisposed');
    expect(events[17].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[17].dep?.valueType, _TestAsyncDep);
    expect(events[17].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[17].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[18].name, 'onValueCleared');
    expect(events[18].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[18].dep?.valueType, NeverCreatedValue);
    expect(events[18].dep?.depHashCode, events[10].dep?.depHashCode);
    expect(events[18].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[19].name, 'onValueCleared');
    expect(events[19].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[19].dep?.valueType, _BrokenDisposeAsyncDep);
    expect(events[19].dep?.depHashCode, events[5].dep?.depHashCode);
    expect(events[19].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[20].name, 'onValueCleared');
    expect(events[20].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[20].dep?.valueType, _TestAsyncDep);
    expect(events[20].dep?.depHashCode, events[1].dep?.depHashCode);
    expect(events[20].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events[21].name, 'onScopeDisposed');
    expect(events[21].scope.type, _BrokenAsyncDepScopeContainer);
    expect(events[21].scope.scopeHashCode, events[0].scope.scopeHashCode);

    expect(events.length, 22);
  });
}

class ObserverEvent {
  final String name;
  final ScopeId scope;
  final DepId? dep;
  final ValueMeta? value;
  final Object? exception;
  final StackTrace? stackTrace;

  ObserverEvent({
    required this.name,
    required this.scope,
    this.dep,
    this.value,
    this.exception,
    this.stackTrace,
  });

  @override
  String toString() =>
      'ObserverEvent{name: $name, scope: $scope, dep: $dep, value: $value, '
      'exception: $exception, stackTrace: $stackTrace}';
}

class TestObserver implements ScopeObserver, DepObserver, AsyncDepObserver {
  final _events = <ObserverEvent>[];

  TestObserver();

  void _log(
    String name,
    ScopeId scope, {
    DepId? dep,
    ValueMeta? value,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    print('$name: $scope, $dep, $value');
    if (exception != null) {
      print('$exception\n$stackTrace');
    }
    _events.add(
      ObserverEvent(
        name: name,
        scope: scope,
        dep: dep,
        value: value,
        exception: exception,
        stackTrace: stackTrace,
      ),
    );
  }

  @override
  void onScopeStartInitialize(ScopeId scope) =>
      _log('onScopeStartInitialize', scope);

  @override
  void onScopeInitialized(ScopeId scope) => _log('onScopeInitialized', scope);

  @override
  void onScopeInitializeFailed(
    ScopeId scope,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log(
        'onScopeInitializeFailed',
        scope,
        exception: exception,
        stackTrace: stackTrace,
      );

  @override
  void onScopeStartDispose(ScopeId scope) => _log('onScopeStartDispose', scope);

  @override
  void onScopeDisposed(ScopeId scope) => _log('onScopeDisposed', scope);

  @override
  void onScopeDisposeDepFailed(
    ScopeId scope,
    DepId dep,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log(
        'onScopeDisposeDepFailed',
        scope,
        dep: dep,
        exception: exception,
        stackTrace: stackTrace,
      );

  @override
  void onValueCreated(ScopeId scope, DepId dep, ValueMeta? valueMeta) =>
      _log('onValueCreated', scope, dep: dep, value: valueMeta);

  @override
  void onValueStartCreate(ScopeId scope, DepId dep) =>
      _log('onValueStartCreate', scope, dep: dep);

  @override
  void onValueCreateFailed(
    ScopeId scope,
    DepId dep,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log(
        'onValueCreateFailed',
        scope,
        dep: dep,
        exception: exception,
        stackTrace: stackTrace,
      );

  @override
  void onValueCleared(ScopeId scope, DepId dep, ValueMeta? valueMeta) =>
      _log('onValueCleared', scope, dep: dep, value: valueMeta);

  @override
  void onDepStartInitialize(ScopeId scope, DepId dep) =>
      _log('onDepStartInitialize', scope, dep: dep);

  @override
  void onDepInitialized(ScopeId scope, DepId dep) =>
      _log('onDepInitialized', scope, dep: dep);

  @override
  void onDepStartDispose(ScopeId scope, DepId dep) =>
      _log('onDepStartDispose', scope, dep: dep);

  @override
  void onDepDisposed(ScopeId scope, DepId dep) =>
      _log('onDepDisposed', scope, dep: dep);

  @override
  void onDepInitializeFailed(
    ScopeId scope,
    DepId dep,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log(
        'onDepInitializeFailed',
        scope,
        dep: dep,
        exception: exception,
        stackTrace: stackTrace,
      );

  @override
  void onDepDisposeFailed(
    ScopeId scope,
    DepId dep,
    Object exception,
    StackTrace stackTrace,
  ) =>
      _log(
        'onDepDisposeFailed',
        scope,
        dep: dep,
        exception: exception,
        stackTrace: stackTrace,
      );
}

class _TestScopeContainer extends ScopeContainer {
  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {myAsyncDep}
      ];

  late final myAsyncDep = asyncDep(() => _TestAsyncDep());

  late final syncDep = dep(() => _SyncDep());
}

class _TestScopeHolder extends ScopeHolder<_TestScopeContainer> {
  _TestScopeHolder(TestObserver listener)
      : super(
          scopeObservers: [listener],
          depObservers: [listener],
          asyncDepObservers: [listener],
        );

  @override
  _TestScopeContainer createContainer() => _TestScopeContainer();
}

class _SyncDep {}

class _TestAsyncDep implements AsyncLifecycle {
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}
}

class _BrokenAsyncDepScopeContainer extends ScopeContainer {
  final bool checkDispose;

  _BrokenAsyncDepScopeContainer({required this.checkDispose});

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {testAsyncDep},
        if (!checkDispose) {brokenInitDep},
        {brokenDisposeDep},
      ];

  late final testAsyncDep = asyncDep(() => _TestAsyncDep());

  late final brokenInitDep = asyncDep(() => _BrokenInitAsyncDep());

  late final brokenDisposeDep = asyncDep(() => _BrokenDisposeAsyncDep());

  late final brokenCreateDep = dep(() => NeverCreatedValue());
}

class _BrokenAsyncDepScopeHolder
    extends ScopeHolder<_BrokenAsyncDepScopeContainer> {
  final bool checkDispose;

  _BrokenAsyncDepScopeHolder(TestObserver listener, {this.checkDispose = false})
      : super(
          scopeObservers: [listener],
          depObservers: [listener],
          asyncDepObservers: [listener],
        );

  @override
  _BrokenAsyncDepScopeContainer createContainer() =>
      _BrokenAsyncDepScopeContainer(checkDispose: checkDispose);
}

class _BrokenInitAsyncDep implements AsyncLifecycle {
  @override
  Future<void> init() async {
    throw BrokenInitException();
  }

  @override
  Future<void> dispose() async {}
}

class _BrokenDisposeAsyncDep implements AsyncLifecycle {
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    throw BrokenDisposeException();
  }
}

class NeverCreatedValue {
  NeverCreatedValue() {
    throw BrokenCreateException();
  }
}

class BrokenCreateException implements Exception {}

class BrokenInitException implements Exception {}

class BrokenDisposeException implements Exception {}
