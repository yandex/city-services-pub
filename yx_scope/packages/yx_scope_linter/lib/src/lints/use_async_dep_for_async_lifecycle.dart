import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/priority.dart';
import 'package:yx_scope_linter/src/utils.dart';

import '../types.dart';

const _asyncDepKeyword = 'asyncDep';

class UseAsyncDepForAsyncLifecycle extends DartLintRule {
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
    context.registry.addClassDeclaration((node) {
      if (!ClassUtils.isScopeContainer(node)) {
        return;
      }
      final deps = ClassUtils.getDepDeclarations(node);
      for (final dep in deps.values) {
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
      message: 'Use `$_asyncDepKeyword` declaration',
      priority: FixPriority.useAsyncDepForAsyncLifecycle.value,
    );
    final methodInvocation = analysisError.data as MethodInvocation;

    builder.addDartFileEdit((builder) {
      builder.addSimpleReplacement(
        methodInvocation.methodName.sourceRange,
        _asyncDepKeyword,
      );
    });
  }
}
