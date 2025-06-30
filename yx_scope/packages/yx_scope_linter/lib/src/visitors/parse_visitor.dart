part of '../resolved_yx_scope_result.dart';

/// Parser that stores parsed data in [result]
class _ParseVisitor extends SimpleAstVisitor<Future> {
  final ResolvedYXScopeResult result;

  _ParseVisitor(this.result);

  @override
  Future visitCompilationUnit(CompilationUnit node) =>
      Future.wait(node.declarations.map((e) async => e.accept(this)));

  @override
  Future visitClassDeclaration(ClassDeclaration node) async {
    final element = node.declaredElement;
    if (element == null) {
      return;
    }

    // Skip if not a scope container or module type
    if (!baseScopeContainerType.isAssignableFromType(element.thisType) &&
        !scopeModuleType.isAssignableFromType(element.thisType)) {
      return;
    }

    // Parse the scope declaration
    final visitor = _ParseScopeDeclaration(ScopeDeclaration(node: node));
    await visitor.visitClassDeclaration(node);

    // Parse initialization queue members
    node.members.accept(
        _ParseInitializeQueueVisitor(visitor.declaration as ScopeDeclaration));

    // Parse dependencies
    await _ParseDependenciesForDepVisitor(visitor.declaration, null).run();

    // Add the completed declaration to results
    result.scopeDeclarations.add(visitor.declaration as ScopeDeclaration);
  }
}
