import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/types.dart';
import 'package:yx_scope_linter/src/utils.dart';

class AvoidChildScopeInInitializeQueue extends DartLintRule {
  static const _code = LintCode(
    name: 'avoid_async_dep_child_scope',
    problemMessage: 'Child scope should not have the same lifecycle as its '
        'parent, and therefore the child scope should be neither '
        'an asyncDep nor a rawAsyncDep',
    correctionMessage: 'If you need some dependencies with the same lifecycle '
        'but grouped together, use ScopeModule instead',
    errorSeverity: ErrorSeverity.WARNING,
  );

  const AvoidChildScopeInInitializeQueue() : super(code: _code);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!ClassUtils.isScopeNode(node)) {
        return;
      }
      final deps = ClassUtils.getDepDeclarations(node);
      for (final dep in deps.values) {
        final methodInvocation = dep.field.fields.childEntities
            .whereType<VariableDeclaration>()
            .expand((e) => e.childEntities.whereType<MethodInvocation>())
            .first;
        final depClass = (methodInvocation.staticType as InterfaceType)
            .typeArguments
            .map((e) => e.element)
            .whereType<ClassElement>()
            .first;
        final isScopeHolder = childScopeHolderValueType.isSuperOf(depClass);
        final isScopeContainer =
            scopeContainerValueType.isAssignableFrom(depClass);
        final isAsyncLifecycle = asyncLifecycleType.isAssignableFrom(depClass);
        if (dep.isAsync &&
            (isScopeHolder || (isScopeContainer && isAsyncLifecycle))) {
          reporter.atToken(
            dep.nameToken,
            _code,
          );
        }
      }
    });
  }
}
