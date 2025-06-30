part of '../resolved_yx_scope_result.dart';

/// Visitor that parses scope declarations and their dependencies
/// and put them into [declaration]
class _ParseScopeDeclaration extends SimpleAstVisitor<Future> {
  final BaseScopeDeclaration declaration;

  _ParseScopeDeclaration(this.declaration);

  @override
  Future visitClassDeclaration(ClassDeclaration node) =>
      Future.wait(node.members.map((e) async => e.accept(this)));

  @override
  Future visitFieldDeclaration(FieldDeclaration node) =>
      Future.wait(node.fields.variables.map((e) async => e.accept(this)));

  @override
  Future visitVariableDeclaration(VariableDeclaration node) async {
    final element = node.declaredElement;
    if (element == null) {
      return;
    }

    // Handle dependency declarations
    if (anyDepValueTypes.isExactlyType(element.type)) {
      declaration.addDep(
        DepDeclaration(
          field: node.thisOrAncestorOfType<FieldDeclaration>()!,
          nameToken: node.name,
          type: element.type,
          parent: declaration,
        ),
      );
    }

    // Handle scope module references
    if (scopeModuleType.isAssignableFromType(element.type)) {
      await Future.wait(node.childEntities
          .whereType<AstNode>()
          .map((e) async => e.accept(this)));
    }
  }

  @override
  Future visitInstanceCreationExpression(
      InstanceCreationExpression node) async {
    final library = node.constructorName.type.element?.library;
    if (library == null) {
      return;
    }

    // Resolve the module declaration from its library
    final result = (await library.session.getResolvedLibraryByElement(library))
        as ResolvedLibraryResult;

    final moduleNode = result
        .getElementDeclaration(
            node.constructorName.type.element as ClassElement)!
        .node as ClassDeclaration;

    // Create and register the module declaration
    final moduleDeclaration = ModuleDeclaration(
      parent: declaration,
      nameToken: node.thisOrAncestorOfType<VariableDeclaration>()!.name,
      node: moduleNode,
    );

    declaration.addModule(moduleDeclaration);

    // Recursively parse the module's contents
    await moduleNode.accept(_ParseScopeDeclaration(moduleDeclaration));
  }
}
