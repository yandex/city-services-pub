part of '../resolved_yx_scope_result.dart';

/// Visitor that parses the dependency initialization queue
/// for a [scope] declaration by analyzing the initializeQueue method.
class _ParseInitializeQueueVisitor extends SimpleAstVisitor<void> {
  final ScopeDeclaration scope;

  /// Tracks the current scope during traversal
  late BaseScopeDeclaration _curScope = scope;

  _ParseInitializeQueueVisitor(this.scope);

  @override
  void visitListLiteral(ListLiteral node) {
    // Process all elements in a list literal
    node.visitChildren(this);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    // Create a new queue section for each set/map literal
    scope.addScopeQueue();
    node.visitChildren(this);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final type = node.staticType;
    if (type == null) {
      return;
    }

    // Handle module references - update current scope context
    if (scopeModuleType.isAssignableFromType(type)) {
      final curScope = _curScope.modules[node.name];
      if (curScope != null) {
        _curScope = curScope;
      }
    }

    // Handle dependency references - add to initialization queue
    if (anyDepValueTypes.isAssignableFromType(type)) {
      final dep = _curScope.deps[node.name];
      if (dep != null) {
        scope.addDepToQueue(dep);
      }
      _curScope = scope;
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // Only process the initializeQueue method
    if (node.declaredElement?.name != MethodNames.initializeQueue) {
      return;
    }
    // Process the method body to find dependencies
    node.body.visitChildren(this);
  }
}
