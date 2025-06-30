import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/types.dart';

import '../yx_scope_lint_rule.dart';

class PassAsyncLifecycleInInitializeQueue extends YXScopeLintRule {
  static const _code = LintCode(
    name: 'pass_async_lifecycle_in_initialize_queue',
    problemMessage:
        'asyncDep (or rawAsyncDep) must be passed to initializeQueue. '
        'Otherwise init/dispose methods will not be called.',
    correctionMessage: 'Override method initializeQueue in the current scope'
        ' and pass the Dep there',
    errorSeverity: ErrorSeverity.WARNING,
  );

  const PassAsyncLifecycleInInitializeQueue() : super(code: _code);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    yxScopeRegistry(context).addScopeDeclarations((scope) {
      if (scopeModuleType.isAssignableFromType(scope.type)) {
        return;
      }
      for (final dep in scope.deps.values) {
        if (dep.isSync) {
          continue;
        }
        if (!scope.initializeQueue.expand((element) => element).contains(dep)) {
          reporter.atToken(
            dep.nameToken,
            _code,
          );
        }
      }
    });
  }
}
