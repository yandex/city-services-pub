import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/names.dart';
import 'package:yx_scope_linter/src/utils.dart';

class PassAsyncLifecycleInInitializeQueue extends DartLintRule {
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
    context.registry.addClassDeclaration((node) {
      if (!ClassUtils.isScopeContainer(node)) {
        return;
      }
      final initializeQueueMethod = ClassUtils.getInstanceMethods(node)
          .cast<MethodDeclaration?>()
          .firstWhere(
            (element) => element?.name.lexeme == MethodNames.initializeQueue,
            orElse: () => null,
          );

      final depsInQueue = initializeQueueMethod?.body.childEntities
          .whereType<ListLiteral>()
          .expand((e) => e.elements)
          .expand((e) => e.childEntities.whereType<SimpleIdentifier>());

      final queueDeps = depsInQueue?.map((e) => e.name).toSet() ?? {};
      final deps = ClassUtils.getDepDeclarations(node);
      for (final dep in deps.values) {
        if (dep.isSync) {
          continue;
        }
        if (!queueDeps.contains(dep.name)) {
          reporter.atToken(
            dep.nameToken,
            _code,
          );
        }
      }
    });
  }
}
