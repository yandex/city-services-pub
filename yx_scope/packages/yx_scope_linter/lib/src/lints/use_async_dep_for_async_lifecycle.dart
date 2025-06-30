import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../models/dep.dart';
import '../priority.dart';
import '../types.dart';
import '../yx_scope_lint_rule.dart';

const _asyncDepKeyword = 'asyncDep';

class UseAsyncDepForAsyncLifecycle extends YXScopeLintRule {
  static const _code = LintCode(
    name: 'use_async_dep_for_async_lifecycle',
    problemMessage:
        'Dependency implements AsyncLifecycle interface, but uses `dep` declaration. '
        'In this case init/dispose methods will not be invoked.',
    correctionMessage: 'You should either use `$_asyncDepKeyword` declaration '
        'or do not implement AsyncLifecycle interface.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  const UseAsyncDepForAsyncLifecycle() : super(code: _code);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    yxScopeRegistry(context).addScopeDeclarations((module) {
      void checkAsyncDeps(BaseScopeDeclaration module) {
        for (final dep in module.deps.values) {
          if (dep.isAsync) {
            continue;
          }
          final methodInvocation = dep.field.fields.childEntities
              .whereType<VariableDeclaration>()
              .expand((e) => e.childEntities.whereType<MethodInvocation>())
              .first;
          final depClass = (methodInvocation.staticType as InterfaceType)
              .typeArguments
              .map((e) => e.element)
              .whereType<ClassElement>()
              .first;
          final implementsAsyncLifecycle =
              asyncLifecycleType.isAssignableFromType(depClass.thisType);
          if (implementsAsyncLifecycle) {
            reporter.atToken(
              methodInvocation.methodName.token,
              _code,
              data: methodInvocation,
            );
          }
        }
        for (final module in module.modules.values) {
          checkAsyncDeps(module);
        }
      }

      checkAsyncDeps(module);
    });
  }

  @override
  List<Fix> getFixes() => [UseAsyncDepForAsyncLifecycleFix()];
}

class UseAsyncDepForAsyncLifecycleFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final builder = reporter.createChangeBuilder(
      message: 'Use `asyncDep` declaration',
      priority: FixPriority.useAsyncDepForAsyncLifecycle.value,
    );
    final methodInvocation = analysisError.data as MethodInvocation;

    builder.addDartFileEdit((builder) {
      builder.addSimpleReplacement(
        methodInvocation.methodName.sourceRange,
        'asyncDep',
      );
    });
  }
}
