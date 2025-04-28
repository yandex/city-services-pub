import 'base_scope_container.dart';

/// Root [BaseScopeContainer] without parent scope.
///
/// {@macro base_scope_container}
abstract class ScopeContainer extends BaseScopeContainer {
  ScopeContainer({String? name}) : super(name: name) {
    _initializeQueueNoDuplications(this);
  }
}

/// {@macro child_scope_container}
abstract class ChildScopeContainer<Parent extends Scope>
    extends BaseScopeContainer with ChildScopeContainerMixin<Parent> {
  ChildScopeContainer({
    required Parent parent,
    String? name,
  }) : super(name: name) {
    this.parent = parent;
    _initializeQueueNoDuplications(this);
  }
}

/// {@macro data_scope_container}
abstract class DataScopeContainer<Data> extends ScopeContainer
    with DataScopeContainerMixin<Data> {
  DataScopeContainer({
    required Data data,
    String? name,
  }) : super(name: name) {
    this.data = data;
    _initializeQueueNoDuplications(this);
  }
}

/// Combines [ChildScopeContainer] and [DataScopeContainer].
///
/// [ChildScopeContainer]:
/// {@macro child_scope_container}
///
/// [DataScopeContainer]:
/// {@macro data_scope_container}
abstract class ChildDataScopeContainer<Parent extends Scope, Data>
    extends BaseScopeContainer
    with ChildScopeContainerMixin<Parent>, DataScopeContainerMixin<Data> {
  ChildDataScopeContainer({
    required Parent parent,
    required Data data,
    String? name,
  }) : super(name: name) {
    this.data = data;
    this.parent = parent;
    _initializeQueueNoDuplications(this);
  }
}

/// Checks if no duplicated async dependency instances
/// added into initializeQueue.
void _initializeQueueNoDuplications<Container extends BaseScopeContainer>(
    Container scope) {
  // ignore: invalid_use_of_protected_member
  final deps = scope.initializeQueue.expand((depSet) => depSet);
  final counter = <AsyncDep, int>{};
  for (final dep in deps) {
    counter[dep] = (counter[dep] ?? 0) + 1;
  }
  final duplications = counter.entries.where((entry) => entry.value > 1);
  assert(
    duplications.isEmpty,
    '(${scope.runtimeType}) Following async dependencies has been added '
    'to initializeQueue multiple times: '
    '[${duplications.map((e) => '${e.key.runtimeType}: ${e.value}').join(', ')}]',
  );
}
