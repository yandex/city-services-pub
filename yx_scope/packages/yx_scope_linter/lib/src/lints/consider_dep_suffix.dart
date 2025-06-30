import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/extensions.dart';
import 'package:yx_scope_linter/src/utils.dart';

const _suffix = 'Dep';

class ConsiderDepSuffix extends DartLintRule {
  static const _code = LintCode(
    name: 'consider_dep_suffix',
    problemMessage: 'Consider using suffix `$_suffix` for the name of your Dep',
    correctionMessage: 'Add suffix `$_suffix` like this: `entityName$_suffix`',
    errorSeverity: ErrorSeverity.INFO,
  );

  const ConsiderDepSuffix() : super(code: _code);

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
      for (final dep in deps.values) {
        if (dep.name.endsWith(_suffix)) {
          continue;
        }

        reporter.atToken(
          dep.nameToken,
          _code.copyWith(
            correctionMessage: 'Change the name to `${dep.name}$_suffix`',
          ),
        );
      }
    });
  }
}
