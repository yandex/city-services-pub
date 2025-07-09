import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:yx_scope_linter/src/names.dart';

import 'models/dep.dart';
import 'types.dart';
import 'yx_scope_registry.dart';

part 'visitors/parse_visitor.dart';
part 'visitors/parse_dependencies_for_dep_visitor.dart';
part 'visitors/parse_scope_declaration_visitor.dart';
part 'visitors/parse_initialize_queue_visitor.dart';

/// Class that analyzes all files and stores parsed data for analysis
class ResolvedYXScopeResult {
  final List<CompilationUnit> units;
  ResolvedYXScopeResult._(this.units);

  static Future<ResolvedYXScopeResult> from(
    List<CompilationUnit> units,
  ) async {
    final result = ResolvedYXScopeResult._(units);
    final visitor = _ParseVisitor(result);

    for (final unit in units) {
      /// Skip generated files during parsing
      const generatedExtensions = {'.freezed.dart', '.g.dart'};
      final shortName = unit.declaredElement?.source.shortName ?? '';
      if (generatedExtensions.any(shortName.endsWith)) {
        continue;
      }
      await unit.accept(visitor);
    }

    return result;
  }

  /// Units contain resolved data that can be used to extract ClassDeclaration
  /// from [element]
  ClassDeclaration? classDeclarationByElement(Element element) {
    for (final unit in units) {
      final declarations = unit.declarations
          .where((declaration) => declaration.declaredElement == element)
          .whereType<ClassDeclaration>();
      if (declarations.isEmpty) {
        return null;
      }
      return declarations.first;
    }
    return null;
  }

  final scopeDeclarations = <ScopeDeclaration>{};

  void accept(YXScopeRegistryVisitor visitor) {
    visitor.visitResolvedUnits(this);
  }

  void visitChildren(YXScopeRegistryVisitor visitor) {
    for (final scopeDeclaration in scopeDeclarations) {
      visitor.visitScopeDeclaration(scopeDeclaration);
    }
  }
}
