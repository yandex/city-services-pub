import 'package:yx_scope/yx_scope.dart';

class SomeScopeHolder extends ScopeHolder<_ParentScopeContainer> {
  @override
  _ParentScopeContainer createContainer() => _ParentScopeContainer();
}

class _ParentScopeContainer extends ScopeContainer {
  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {_childScopeHolderRawAsyncDep, _childScopeHolderAsyncDep}
      ];

  // expect_lint: avoid_async_dep_child_scope
  late final _childScopeHolderRawAsyncDep = rawAsyncDep(
    () => _ChildScopeHolder(this),
    init: (dep) async => await dep.create(),
    dispose: (dep) async => await dep.drop(),
  );

  // expect_lint: avoid_async_dep_child_scope
  late final _childScopeHolderAsyncDep =
      asyncDep(() => _ChildAsyncLifecycleScopeContainer());
}

class ParentScopeModule extends ScopeModule<_ParentScopeContainer> {
  ParentScopeModule(super.container);

  // expect_lint: avoid_async_dep_child_scope
  late final childScopeHolderRawAsyncDep = rawAsyncDep(
    () => _ChildScopeHolder(this.container),
    init: (dep) async => await dep.create(),
    dispose: (dep) async => await dep.drop(),
  );
}

class _ChildScopeHolder
    extends ChildScopeHolder<_ChildScopeContainer, _ParentScopeContainer> {
  _ChildScopeHolder(super.parent);

  @override
  _ChildScopeContainer createContainer(_ParentScopeContainer parent) =>
      _ChildScopeContainer(parent: parent);
}

class _ChildScopeContainer extends ChildScopeContainer<_ParentScopeContainer> {
  _ChildScopeContainer({required super.parent});
}

class _ChildAsyncLifecycleScopeContainer extends ScopeContainer
    implements AsyncLifecycle {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}
}
