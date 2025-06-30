import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/extensions.dart';
import 'package:yx_scope_linter/src/models/dep.dart';
import 'package:yx_scope_linter/src/utils.dart';

class DepCycle extends DartLintRule {
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
    context.registry.addClassDeclaration((node) {
      if (!ClassUtils.isScopeContainer(node)) {
        return;
      }
      final deps = ClassUtils.getDepDeclarations(node);
      final depsSet = deps.keys.toSet();
      final dependencies = <String, Set<String>>{};
      for (final entry in deps.entries) {
        final dep = entry.value;
        final depSet = <String>{};
        for (final maybeDep in depsSet) {
          if (dep.dependencies.contains(maybeDep)) {
            depSet.add(maybeDep);
          }
        }
        dependencies[dep.name] = depSet;
      }
      final cycles = detectCycles(dependencies);
      if (cycles.isNotEmpty) {
        for (final cycle in cycles) {
          final cycleDeps =
              cycle.map((e) => deps[e]).whereType<DepDeclaration>();
          for (final dep in cycleDeps) {
            reporter.atToken(
              dep.nameToken,
              _code.copyWith(
                problemMessage:
                    '$_message: ${cycleDeps.map((e) => e.name).join(' <- ')}'
                    ' <- ${cycleDeps.first.name}',
              ),
            );
          }
        }
      }
    });
  }

  List<List<String>> detectCycles(Map<String, Set<String>> dependencies) {
    final cycles = <List<String>>[];
    final visited = <String>{};
    final inStack = <String>{};

    void dfs(String entity, List<String> currentCycle) {
      visited.add(entity);
      inStack.add(entity);
      currentCycle.add(entity);

      for (String dependency in (dependencies[entity] ?? <String>{})) {
        if (!visited.contains(dependency)) {
          dfs(dependency, currentCycle);
        } else if (inStack.contains(dependency)) {
          cycles.add(currentCycle.sublist(currentCycle.indexOf(dependency)));
        }
      }

      inStack.remove(entity);
      currentCycle.remove(entity);
    }

    for (String entity in dependencies.keys) {
      if (!visited.contains(entity)) {
        dfs(entity, []);
      }
    }

    return cycles;
  }
}
