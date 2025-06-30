import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/extensions.dart';

import '../models/dep.dart';
import '../yx_scope_lint_rule.dart';

class DepCycle extends YXScopeLintRule {
  static const _name = 'dep_cycle';
  static const _message = 'The cycle is detected';
  static const _code = LintCode(
    name: _name,
    problemMessage: _message,
    errorSeverity: ErrorSeverity.ERROR,
  );

  const DepCycle() : super(code: _code);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    yxScopeRegistry(context).addScopeDeclarations((scope) {
      final cycles = detectCycles(scope);
      for (final cycle in cycles) {
        final errorCode = _code.copyWith(
          problemMessage: '$_message: ${cycle.map((e) => e).join(' <- ')}'
              ' <- ${cycle.first}',
        );

        for (final dep in cycle) {
          if (dep.parent == scope) {
            reporter.atToken(
              dep.nameToken,
              errorCode,
            );
          } else {
            reporter.atToken(
              (dep.parent as ModuleDeclaration).nameToken!,
              errorCode,
            );
          }
        }
      }
    });
  }

  List<List<DepDeclaration>> detectCycles(BaseScopeDeclaration module) {
    final cycles = <List<DepDeclaration>>[];
    final visited = <DepDeclaration>{};
    final inStack = <DepDeclaration>{};

    void dfs(DepDeclaration entity, List<DepDeclaration> currentCycle) {
      visited.add(entity);
      inStack.add(entity);
      currentCycle.add(entity);

      for (final dependency in entity.deps.values) {
        if (!visited.contains(dependency)) {
          dfs(dependency, currentCycle);
        } else if (inStack.contains(dependency)) {
          cycles.add(currentCycle.sublist(currentCycle.indexOf(dependency)));
        }
      }

      inStack.remove(entity);
      currentCycle.remove(entity);
    }

    for (final entity in module.deps.values) {
      if (!visited.contains(entity)) {
        dfs(entity, []);
      }
    }

    return cycles;
  }
}
