import 'package:test/test.dart';
import 'package:yx_scope/yx_scope.dart';

import 'utils/test_logger.dart';

void main() {
  setUp(() {
    ScopeObservatory.logger = const TestLogger();
  });

  test('child scope is not created with the parent', () async {
    final parentHolder = _ParentScopeHolder();
    await parentHolder.create();
    final childHolder = parentHolder.scope?.childScopeDep.get;

    expect(parentHolder.scope, isNotNull);
    expect(childHolder, isNotNull);
    expect(childHolder?.scope, isNull);
  });

  test('child scope disposed when parent scope dropped', () async {
    final parentHolder = _ParentScopeHolder();
    await parentHolder.create();
    final childHolder = parentHolder.scope?.childScopeDep.get;

    expect(parentHolder.scope, isNotNull);
    expect(childHolder, isNotNull);
    expect(childHolder?.scope, isNull);

    final testData = _TestData();
    await childHolder?.create(testData);

    expect(parentHolder.scope, isNotNull);
    expect(childHolder, isNotNull);
    expect(childHolder?.scope, isNotNull);

    final actualData = childHolder?.scope?.data;
    final actualChildAsyncDep = childHolder?.scope?.childAsyncDep.get;
    expect(actualChildAsyncDep?._initialized, isTrue);

    expect(actualData, testData);

    await parentHolder.drop();

    expect(parentHolder.scope, isNull);
    expect(childHolder?.scope, isNull);
    expect(actualChildAsyncDep?._initialized, isFalse);
  });

  test('parent dep instances are the same as provided in child', () async {
    final parentHolder = _ParentScopeHolder();
    await parentHolder.create();
    final childHolder = parentHolder.scope?.childScopeDep.get;

    expect(parentHolder.scope, isNotNull);
    expect(childHolder, isNotNull);
    expect(childHolder?.scope, isNull);

    final testData = _TestData();
    await childHolder?.create(testData);

    expect(parentHolder.scope, isNotNull);
    expect(childHolder, isNotNull);
    expect(childHolder?.scope, isNotNull);

    // data is not created twice
    expect(
      parentHolder.scope?.childScopeDep.get.scope?.data,
      parentHolder.scope?.childScopeDep.get.scope?.data,
    );

    expect(
      parentHolder.scope?.parentDep.get,
      parentHolder.scope?.childScopeDep.get.scope?.childDep.get.parentDep,
    );
    expect(
      parentHolder.scope?.parentAsyncDep.get,
      parentHolder.scope?.childScopeDep.get.scope?.childDep.get.parentAsyncDep,
    );
    expect(
      testData,
      parentHolder.scope?.childScopeDep.get.scope?.childDep.get.data,
    );
    expect(
      parentHolder.scope?.parentDep.get,
      parentHolder.scope?.childScopeDep.get.scope?.childAsyncDep.get.parentDep,
    );
    expect(
      parentHolder.scope?.parentAsyncDep.get,
      parentHolder
          .scope?.childScopeDep.get.scope?.childAsyncDep.get.parentAsyncDep,
    );

    await childHolder?.drop();

    expect(parentHolder.scope, isNotNull);
    expect(childHolder, isNotNull);
    expect(childHolder?.scope, isNull);
  });

  test(
      'Two different scope trees can contain deps with the same type and its different instances',
      () async {
    final parentHolder1 = _ParentScopeHolder();
    final parentHolder2 = _ParentScopeHolder();

    expect(
      parentHolder1.scope?.parentDep.get,
      parentHolder2.scope?.parentDep.get,
    );
    expect(
      parentHolder1.scope?.parentAsyncDep.get,
      parentHolder2.scope?.parentAsyncDep.get,
    );
    expect(
      parentHolder1.scope?.childScopeDep.get.scope?.childDep.get,
      parentHolder2.scope?.childScopeDep.get.scope?.childDep.get,
    );
    expect(
      parentHolder1.scope?.childScopeDep.get.scope?.childAsyncDep.get,
      parentHolder2.scope?.childScopeDep.get.scope?.childAsyncDep.get,
    );
  });
}

class _ParentScopeContainer extends ScopeContainer {
  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {parentAsyncDep}
      ];

  late final childScopeDep = dep(() => _ChildScopeHolder(this));

  late final childWithDuplicationScopeDep =
      dep(() => _ChildWithDuplicationScopeHolder(this));

  late final parentDep = dep(() => _ParentDep());

  late final parentAsyncDep = asyncDep(() => _ParentAsyncDep());
}

class _ParentScopeHolder extends ScopeHolder<_ParentScopeContainer> {
  @override
  _ParentScopeContainer createContainer() => _ParentScopeContainer();
}

class _ChildScopeContainer
    extends ChildDataScopeContainer<_ParentScopeContainer, _TestData> {
  _ChildScopeContainer({
    required _ParentScopeContainer parent,
    required _TestData data,
  }) : super(parent: parent, data: data);

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {childAsyncDep}
      ];

  late final childDep = dep(
    () => _ChildDep(
      data,
      parent.parentDep.get,
      parent.parentAsyncDep.get,
    ),
  );

  late final childAsyncDep = asyncDep(
    () => _ChildAsyncDep(
      parent.parentDep.get,
      parent.parentAsyncDep.get,
      childDep.get,
    ),
  );
}

class _ChildScopeHolder extends ChildDataScopeHolder<_ChildScopeContainer,
    _ParentScopeContainer, _TestData> {
  _ChildScopeHolder(_ParentScopeContainer parent) : super(parent);

  @override
  _ChildScopeContainer createContainer(
    _ParentScopeContainer parent,
    _TestData data,
  ) =>
      _ChildScopeContainer(data: data, parent: parent);
}

class _ChildWithDuplicationScopeContainer
    extends ChildScopeContainer<_ParentScopeContainer> {
  _ChildWithDuplicationScopeContainer({required _ParentScopeContainer parent})
      : super(parent: parent);

  late final duplicatedParentDep = dep(() => _ParentDep());

  late final duplicatedParentAsyncDep = asyncDep(() => _ParentAsyncDep());

  late final duplicatedChildDep = dep(
    () => _ChildDep(
      _TestData(),
      parent.parentDep.get,
      parent.parentAsyncDep.get,
    ),
  );
}

class _ChildWithDuplicationScopeHolder extends ChildScopeHolder<
    _ChildWithDuplicationScopeContainer, _ParentScopeContainer> {
  _ChildWithDuplicationScopeHolder(_ParentScopeContainer parent)
      : super(parent);

  @override
  _ChildWithDuplicationScopeContainer createContainer(
          _ParentScopeContainer parent) =>
      _ChildWithDuplicationScopeContainer(parent: parent);
}

class _ParentDep {}

class _ParentAsyncDep implements AsyncLifecycle {
  // ignore: unused_field
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

class _ChildDep {
  final _TestData data;
  final _ParentDep parentDep;
  final _ParentAsyncDep parentAsyncDep;

  const _ChildDep(this.data, this.parentDep, this.parentAsyncDep);
}

class _ChildAsyncDep implements AsyncLifecycle {
  final _ParentDep parentDep;
  final _ParentAsyncDep parentAsyncDep;
  final _ChildDep childDep;
  var _initialized = false;

  _ChildAsyncDep(
    this.parentDep,
    this.parentAsyncDep,
    this.childDep,
  );

  @override
  Future<void> init() async {
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}

class _TestData {}
