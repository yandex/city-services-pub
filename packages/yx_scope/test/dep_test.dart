import 'package:test/test.dart';
import 'package:yx_scope/advanced.dart';
import 'package:yx_scope/src/monitoring/raw_observers.dart';
import 'package:yx_scope/yx_scope.dart';

import 'utils/test_logger.dart';
import 'utils/utils.dart';

void main() {
  final observer = _TestObserver();

  setUp(() {
    _TestDep.instances.clear();
    _TestAsyncDepNoAsyncLifecycle.instances.clear();
    _TestAsyncDep.instances.clear();
    ScopeObservatory.logger = const TestLogger();

    RawScopeObserver.override = observer;
    RawDepObserver.override = observer;
    RawAsyncDepObserver.override = observer;
  });

  tearDown(() {
    observer.scopeDeps.clear();
    RawScopeObserver.override = null;
    RawDepObserver.override = null;
    RawAsyncDepObserver.override = null;
  });

  group('sync dependencies', () {
    test('dep is created lazily only when dep.get is called', () {
      final scope = _TestScope();
      expect(_TestDep.instances.isEmpty, isTrue);

      final dep = scope.myDep;
      expect(_TestDep.instances.isEmpty, isTrue);

      final myDep = dep.get;
      expect(_TestDep.instances.length, 1);
      // dep.get returns the same instance as was created
      expect(_TestDep.instances.first, myDep);
    });

    test('dep creates only one instance', () {
      final scope = _TestScope();
      expect(scope.myDep.get, scope.myDep.get);
    });

    test('dep is registered in observer lazily', () {
      final scope = _TestScope();
      expect(observer.scopeDeps['_TestScope'], isNull);

      final dep = scope.myDep.get;
      expect(
        observer.scopeDeps['_TestScope']?.first,
        dep.runtimeType.toString(),
      );
    });

    test(
        'dependencies with the same type but different names'
        ' is registered separately in observer', () {
      final scope = _TestScope();
      expect(observer.scopeDeps['_TestScope'], isNull);

      final dep1 = scope.myDep.get;
      expect(
        observer.scopeContainsDep('_TestScope', dep1.runtimeType.toString()),
        isTrue,
      );

      final dep2 = scope.myDuplicatedDep.get;
      expect(
        observer.scopeContainsDep('_TestScope', dep2.runtimeType.toString()),
        isTrue,
      );
    });

    test('dep returns non-nullable value', () {
      final scope = _TestScope();
      expect(observer.scopeDeps['_TestScope'], isNull);

      final dep = scope.myNullableDep.get;
      expect(
        dep,
        isNotNull,
      );
      expect(
        observer.scopeDeps['_TestScope']?.first
            .startsWith(dep.runtimeType.toString()),
        isTrue,
      );
    });

    test('dep returns null value', () {
      final scope = _TestScope(isNullableDep: true);
      expect(observer.scopeDeps['_TestScope'], isNull);

      final dep = scope.myNullableDep.get;
      expect(
        dep,
        isNull,
      );
    });
  });

  group('async dependencies', () {
    test(
        'async dep initialized lazily on scope init and disposed on scope dispose',
        () async {
      final scopeHolder = _TestAsyncDepScopeHolder();
      expect(_TestAsyncDepNoAsyncLifecycle.instances.isEmpty, isTrue);
      expect(_TestAsyncDep.instances.isEmpty, isTrue);

      await scopeHolder.create();
      final scope = scopeHolder.scope;
      if (scope == null) {
        throw Exception('Scope must be no-null here');
      }

      final asyncDep = scope.myAsyncDep;
      // no need to call dep.get, because it will be called during scope initialization
      expect(_TestAsyncDepNoAsyncLifecycle.instances.length, 1);

      final secondAsyncDep = scope.mySecondAsyncDep;
      // no need to call dep.get, because it will be called during scope initialization
      expect(_TestAsyncDep.instances.length, 1);

      final depInstance = asyncDep.get;
      expect(_TestAsyncDepNoAsyncLifecycle.instances.first, depInstance);
      expect(depInstance._loaded, isTrue);

      final secondDepInstance = secondAsyncDep.get;
      expect(_TestAsyncDep.instances.first, secondDepInstance);
      expect(secondDepInstance._initialized, isTrue);

      // async dep creates only one instance
      expect(depInstance, asyncDep.get);
      expect(asyncDep.get, asyncDep.get);
      expect(secondDepInstance, secondAsyncDep.get);
      expect(secondAsyncDep.get, secondAsyncDep.get);

      await scopeHolder.drop();

      expect(depInstance._loaded, isFalse);
      expect(secondDepInstance._initialized, isFalse);
    });

    test('uninitialized async dep throws an assertion when calling dep.get',
        () async {
      final scopeHolder = _TestAsyncDepScopeHolder();
      expect(_TestAsyncDep.instances.isEmpty, isTrue);

      await scopeHolder.create();
      final scope = scopeHolder.scope;
      if (scope == null) {
        throw Exception('Scope must be no-null here');
      }

      final uninitializedAsyncDep = scope.uninitializedAsyncDep;
      // We have 2 _TestAsyncDep deps in the scope
      // (mySecondAsyncDep and uninitializedAsyncDep),
      // but we forgotten to initialize this dep,
      // so there is only one instance after scope creation.
      expect(_TestAsyncDep.instances.length, 1);

      await expectAssertion(() => uninitializedAsyncDep.get);

      await scopeHolder.drop();
    });
  });
}

class _TestScope extends ScopeContainer {
  final bool isNullableDep;

  _TestScope({this.isNullableDep = false});

  late final myDep = dep(() => _TestDep());

  late final myDuplicatedDep = dep(() => _TestDep(), name: 'duplicate');

  late final myNullableDep = dep(() => isNullableDep ? null : _TestDep());
}

class _TestDep {
  static final instances = <_TestDep>[];

  _TestDep() {
    instances.add(this);
  }
}

class _TestAsyncDepNoAsyncLifecycle {
  static final instances = <_TestAsyncDepNoAsyncLifecycle>[];

  _TestAsyncDepNoAsyncLifecycle() {
    instances.add(this);
  }

  var _loaded = false;

  Future<void> load() async {
    _loaded = true;
  }

  void clear() {
    _loaded = false;
  }
}

class _TestAsyncDep implements AsyncLifecycle {
  static final instances = <_TestAsyncDep>[];

  _TestAsyncDep() {
    instances.add(this);
  }

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

class _TestAsyncDepScope extends ScopeContainer {
  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {myAsyncDep, mySecondAsyncDep}
      ];

  late final myAsyncDep = rawAsyncDep(
    () => _TestAsyncDepNoAsyncLifecycle(),
    init: (dep) async => dep.load(),
    dispose: (dep) async => dep.clear(),
  );

  late final mySecondAsyncDep = asyncDep(() => _TestAsyncDep());

  late final uninitializedAsyncDep = asyncDep(
    () => _TestAsyncDep(),
    name: 'uninitialized',
  );
}

class _TestAsyncDepScopeHolder extends ScopeHolder<_TestAsyncDepScope> {
  @override
  _TestAsyncDepScope createContainer() => _TestAsyncDepScope();
}

class _TestObserver implements RawScopeObserver, RawAsyncDepObserver {
  final scopeDeps = <String, Set<String>>{};

  _TestObserver();

  @override
  void onDepDisposeFailed(
    BaseScopeContainer scope,
    Dep<dynamic> dep,
    Object exception,
    StackTrace stackTrace,
  ) {}

  @override
  void onDepDisposed(BaseScopeContainer scope, Dep<dynamic> dep) {}

  @override
  void onDepInitializeFailed(
    BaseScopeContainer scope,
    Dep<dynamic> dep,
    Object exception,
    StackTrace stackTrace,
  ) {}

  @override
  void onDepInitialized(BaseScopeContainer scope, Dep<dynamic> dep) {}

  @override
  void onDepStartDispose(BaseScopeContainer scope, Dep<dynamic> dep) {}

  @override
  void onDepStartInitialize(BaseScopeContainer scope, Dep<dynamic> dep) {}

  @override
  void onScopeDisposeDepFailed(
    BaseScopeContainer scope,
    Dep<dynamic> dep,
    Object exception,
    StackTrace stackTrace,
  ) {}

  @override
  void onScopeDisposed(BaseScopeContainer scope) =>
      scopeDeps.remove(ScopeMeta(scope).id.type.toString());

  @override
  void onScopeInitializeFailed(
    BaseScopeContainer scope,
    Object exception,
    StackTrace stackTrace,
  ) {}

  @override
  void onScopeInitialized(BaseScopeContainer scope) {}

  @override
  void onScopeStartDispose(BaseScopeContainer scope) {}

  @override
  void onScopeStartInitialize(BaseScopeContainer scope) {
    scopeDeps[ScopeMeta(scope).id.type.toString()] = {};
  }

  @override
  void onValueCreateFailed(
    BaseScopeContainer scope,
    Dep<dynamic> dep,
    Object exception,
    StackTrace stackTrace,
  ) {}

  @override
  void onValueStartCreate(BaseScopeContainer scope, Dep<dynamic> dep) {}

  @override
  void onValueCreated(
      BaseScopeContainer scope, Dep<dynamic> dep, Object? value) {
    final scopeMeta = ScopeMeta(scope);
    final depMeta = DepMeta(dep);
    final deps = scopeDeps[scopeMeta.id.type.toString()] ?? <String>{};
    scopeDeps[scopeMeta.id.type.toString()] = deps;
    deps.add(depMeta.id.valueType.toString());
  }

  @override
  void onValueCleared(
          BaseScopeContainer scope, Dep<dynamic> dep, Object? value) =>
      scopeDeps[ScopeMeta(scope).id.type.toString()]!
          .remove(DepMeta(dep).id.valueType.toString());

  bool scopeContainsDep(String scopeType, String depType) =>
      scopeDeps[scopeType]?.contains(depType) ?? false;
}
