import 'models/dep.dart';
import 'resolved_yx_scope_result.dart';

/// An entity that provides the ability to track parsed data
class YXScopeRegistry {
  /// This method provides the parsing result to subscribers
  void run(ResolvedYXScopeResult result) {
    result.accept(YXScopeRegistryVisitor(this));
  }

  final List<void Function(ScopeDeclaration scope)> _forScopeDeclarations = [];

  /// This method provides the ability to track parsed scope classes
  void addScopeDeclarations(void Function(ScopeDeclaration scope) listener) {
    _forScopeDeclarations.add(listener);
  }
}

/// This visitor simply notifies all subscribers
class YXScopeRegistryVisitor {
  final YXScopeRegistry _registry;

  YXScopeRegistryVisitor(this._registry);

  void visitResolvedUnits(ResolvedYXScopeResult result) {
    result.visitChildren(this);
  }

  void visitScopeDeclaration(ScopeDeclaration result) {
    for (final listener in _registry._forScopeDeclarations) {
      listener(result);
    }
  }
}
