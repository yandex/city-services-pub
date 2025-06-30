import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/extensions.dart';

import '../models/dep.dart';
import '../priority.dart';
import '../yx_scope_lint_rule.dart';

const _suffix = 'Dep';

class ConsiderDepSuffix extends YXScopeLintRule {
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
    yxScopeRegistry(context).addScopeDeclarations((module) {
      void checkSuffix(BaseScopeDeclaration module) {
        for (final dep in module.deps.values) {
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

        for (final module in module.modules.values) {
          checkSuffix(module);
        }
      }

      checkSuffix(module);
    });
  }

  @override
  List<Fix> getFixes() => [ConsiderDepSuffixAssist()];
}

class ConsiderDepSuffixAssist extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final changeBuilder = reporter.createChangeBuilder(
      message: analysisError.correctionMessage!,
      priority: FixPriority.considerDepSuffix.value,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleInsertion(
        analysisError.sourceRange.end,
        _suffix,
      );
    });
  }
}
