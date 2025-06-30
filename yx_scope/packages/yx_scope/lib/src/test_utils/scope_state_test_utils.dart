part of '../base_scope_container.dart';

/// The class that has access to private fields of the given [ScopeStateHolder]
@visibleForTesting
class TestableScopeStateHolder<Scope> {
  final ScopeStateHolder<Scope> holder;

  @visibleForTesting
  const TestableScopeStateHolder(this.holder);

  LinkedList<Entry<Scope>> get listeners => holder._listeners;
}
