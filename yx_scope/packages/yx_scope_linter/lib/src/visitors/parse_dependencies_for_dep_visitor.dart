part of '../resolved_yx_scope_result.dart';

/// Visitor that analyzes and establishes dependency relationships between
/// different dependencies within a [scope] hierarchy.
class _ParseDependenciesForDepVisitor extends GeneralizingAstVisitor<Future> {
  final BaseScopeDeclaration scope;
  DepDeclaration? dep;

  /// Tracks the current scope during traversal (changes when processing modules)
  late BaseScopeDeclaration _curScope = scope;

  _ParseDependenciesForDepVisitor(this.scope, this.dep);

  /// Main execution method that processes all dependencies and modules
  Future<void> run() async {
    // Process all direct dependencies of the current scope
    for (var dep in scope.deps.values) {
      this.dep = dep;
      await dep.field.fields.variables.first.accept(this);
    }

    // Recursively process all module dependencies
    for (var module in scope.modules.values) {
      await _ParseDependenciesForDepVisitor(module, null).run();
    }
  }

  @override
  Future<void>? visitNode(AstNode node) async {
    // Default visitor behavior - process all child nodes
    for (final node in node.childEntities.whereType<AstNode>()) {
      await node.accept(this);
    }
  }

  @override
  Future<void>? visitSimpleIdentifier(SimpleIdentifier node) async {
    final type = node.staticType;
    if (type == null) {
      return;
    }

    // Handle scope container references
    if (baseScopeContainerType.isAssignableFromType(type)) {
      if (_curScope is ModuleDeclaration) {
        final moduleParent = (_curScope as ModuleDeclaration).parent;
        if (type == moduleParent.type) {
          _curScope = moduleParent;
        }
      }
    }

    // Handle module references - update current scope context
    if (scopeModuleType.isAssignableFromType(type)) {
      final curScope = _curScope.modules[node.name];
      if (curScope != null) {
        _curScope = curScope;
      }
    }

    // Handle method calls that return dependency types
    if (node.staticElement is MethodElement) {
      final methodElement = node.staticElement as MethodElement;

      if (anyDepValueTypes.isExactlyType(methodElement.returnType)) {
        return;
      }

      // Verify the method is in the same library as the current scope
      final element = node.staticElement;
      final library = element?.library;
      final scopeLibrary = _curScope.node.declaredElement?.library;

      if (element == null || library == null || scopeLibrary == null) {
        return;
      }

      if (library != scopeLibrary) {
        return;
      }

      // Process the method declaration to find nested dependencies
      final result = (await library.session
          .getResolvedLibraryByElement(library)) as ResolvedLibraryResult;
      final methodDeclaration =
          result.getElementDeclaration(element)!.node as MethodDeclaration;

      await _ParseDependenciesForDepVisitor(_curScope, dep)
          .visitMethodDeclaration(methodDeclaration);

      _curScope = scope;
    }

    // Handle direct dependency references
    if (anyDepValueTypes.isAssignableFromType(type)) {
      final foundDep = _curScope.deps[node.name];
      if (foundDep != null && dep != null) {
        dep!.addDep(foundDep);
      }
      _curScope = scope;
    }
  }
}
