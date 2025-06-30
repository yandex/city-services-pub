// ignore_for_file: sdk_version_since

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:yx_scope_linter/src/models/dep.dart';

import 'types.dart';

class ClassUtils {
  static bool implementsInterface(ClassElement element, String ancestorName) =>
      element.interfaces
          .map((e) => e.getDisplayString())
          .contains(ancestorName);

  static bool isScopeContainer(ClassDeclaration node) {
    final element = node.declaredElement;
    return element != null
        ? baseScopeContainerType.isAssignableFrom(element)
        : false;
  }

  static bool isModuleScope(ClassDeclaration node) {
    final element = node.declaredElement;
    return element != null ? scopeModuleType.isAssignableFrom(element) : false;
  }

  static bool isScopeNode(ClassDeclaration node) =>
      isScopeContainer(node) || isModuleScope(node);

  static Iterable<FieldDeclaration> getInstanceFields(ClassDeclaration node) {
    return node.members
        .whereType<FieldDeclaration>()
        .where((element) => !element.isStatic);
  }

  static Iterable<MethodDeclaration> getInstanceMethods(ClassDeclaration node) {
    return node.members
        .whereType<MethodDeclaration>()
        .where((element) => !element.isStatic);
  }

  static Map<String, DepDeclaration> getDepDeclarations(ClassDeclaration node) {
    final members = node.members
        .whereType<FieldDeclaration>()
        .where((element) => !element.isStatic);
    final deps = <String, DepDeclaration>{};
    for (final member in members) {
      for (final variable in member.fields.variables) {
        final element = variable.declaredElement;
        if (element == null) {
          continue;
        }

        if (!anyDepValueTypes.isExactlyType(element.type)) {
          continue;
        }

        final dep = DepDeclaration(
          field: member,
          nameToken: variable.name,
          type: element.type,
          dependencies: variable.getDependencies(),
        );

        deps[dep.nameToken.lexeme] = dep;
      }
    }
    return deps;
  }

  const ClassUtils._();
}

extension ElementX on Element {
  T? getAstNode<T extends AstNode>() {
    final library = this.library;
    if (library == null) {
      return null;
    }
    final parsedLib =
        session?.getParsedLibraryByElement(library) as ParsedLibraryResult?;
    final result =
        parsedLib?.getElementDeclaration(this) as ElementDeclarationResult;
    return result.node as T;
  }
}

extension _VariableDeclarationX on VariableDeclaration {
  Set<String> getDependencies() {
    final tokens = childEntities
        .typedExpand<MethodInvocation>()
        .whereType<ArgumentList>()
        .typedExpand<ArgumentList>();

    FunctionBody? body;

    final functionExpression =
        tokens.whereType<FunctionExpression>().firstOrNull;

    if (functionExpression != null) {
      body = functionExpression.body;
    } else {
      final element = tokens.whereType<SimpleIdentifier>().first.staticElement
          as MethodElement;

      final methodDeclaration = element.getAstNode<MethodDeclaration>();
      body = methodDeclaration?.body;
    }

    if (body == null) {
      return {};
    }

    final dependencies = body.getIdentifiers().map((e) => e.toString()).toSet();

    // In SimpleIdentifier's exist string 'get', this is not dependencies. We remove it.
    dependencies.remove('get');
    return dependencies;
  }
}

extension _FunctionBodyX on FunctionBody {
  Iterable<SimpleIdentifier> getIdentifiers() =>
      // has InstanceCreationExpression, Block, MethodInvocation
      childEntities
          // `dep(()=> SomeDep)`
          // get ArgumentList
          .typedExpand<InstanceCreationExpression>()
          // `dep(() {...})`
          // get VariableDeclarationStatement, ReturnStatement
          .typedExpand<Block>()
          // ```
          // {
          //    ...
          //    final value = myDep.get;
          //    final anotherValue = _createValue();
          //    ...
          // }
          // ```
          // get VariableDeclarationList
          .typedExpand<VariableDeclarationStatement>()
          // get VariableDeclaration
          .typedExpand<VariableDeclarationList>()
          // get PrefixedIdentifier, MethodInvocation
          .typedExpand<VariableDeclaration>()
          // `final value = myDep.get;`
          // get SimpleIdentifier
          .typedExpand<PrefixedIdentifier>()
          // ```
          // {
          //    ...
          //    return SomeDep(...)
          // }
          // ```
          // get InstanceCreationExpression, MethodInvocation
          .typedExpand<ReturnStatement>()
          // `SomeDep(...)`
          // get ArgumentList
          .typedExpand<InstanceCreationExpression>()
          // get ArgumentList, SimpleIdentifier
          .expandMethodInvocation()
          // get SimpleIdentifier
          .expandArgumentList()
          // return only SimpleIdentifier without useless for us tokens
          .whereType<SimpleIdentifier>();
}

// callMethod(...)
extension _MethodInvocatinoX on MethodInvocation {
  Iterable<SyntacticEntity> getDependencies() => [
        ..._arguments(),
        ..._identifiers(),
      ];

  // provided deps in arguments
  // callMethod(...)
  Iterable<SyntacticEntity> _arguments() =>
      childEntities.whereType<ArgumentList>().expandArgumentList();

  // deps in body of function:
  // T callMethod() {
  //  ...
  // }
  Iterable<SimpleIdentifier> _identifiers() {
    final staticElement =
        childEntities.whereType<SimpleIdentifier>().firstOrNull?.staticElement;
    if (staticElement == null) {
      return [];
    }
    final declaration = staticElement.getAstNode<MethodDeclaration>();

    if (declaration == null) {
      return [];
    }

    return declaration.body.getIdentifiers();
  }
}

extension _TypedExpandIterableExtension<T extends SyntacticEntity>
    on Iterable<SyntacticEntity> {
  Iterable<SyntacticEntity> typedExpand<R extends AstNode>() =>
      expand((element) {
        if (element is R) {
          return element.childEntities;
        }
        return [element];
      });

  Iterable<SyntacticEntity> expandMethodInvocation() => expand((element) {
        if (element is MethodInvocation) {
          return element.getDependencies();
        }
        return [element];
      });

  Iterable<SyntacticEntity> expandArgumentList() =>
      typedExpand<ArgumentList>().expand((element) {
        // (
        //  prefixedIdentifierDep.get,
        //  ...
        // )
        //
        if (element is PrefixedIdentifier) {
          return element.childEntities;
        }

        // (
        //   namedExpression: namedExpressionDep.get,
        //   ...
        // )
        if (element is NamedExpression) {
          return element.childEntities.typedExpand<PrefixedIdentifier>();
        }

        return [element];
      });
}
