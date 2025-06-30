part of '../../base_scope_container.dart';

/// Extract meta information about [BaseScopeContainer],
/// e.x. ScopeId.
/// This extra class helps to stay the interface of
/// the main [BaseScopeContainer] clean and contain only dep-related method.
///
/// This class must be used only locally and must not be
/// assigned to any field or global final or variable.
class ScopeMeta {
  final BaseScopeContainer _scope;

  const ScopeMeta(BaseScopeContainer scope) : _scope = scope;

  ScopeId get id => _scope._id;
}
