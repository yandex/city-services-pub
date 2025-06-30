import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'resolved_yx_scope_result.dart';
import 'yx_scope_registry.dart';

/// A base [DartLintRule] that parses required classes
/// and provides data for analysis
///
/// Check [YXScopeRegistry] to see what can be tracked
abstract class YXScopeLintRule extends DartLintRule {
  const YXScopeLintRule({required super.code});

  static final _contextKey = Object();

  @override
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
  ) async {
    await _setup(resolver, context);
    await super.startUp(resolver, context);
  }

  YXScopeRegistry yxScopeRegistry(CustomLintContext context) {
    final registry = context.sharedState[_contextKey] as YXScopeRegistry?;
    if (registry == null) {
      throw StateError('YXScopeRegistry not initialized');
    }
    return registry;
  }

  Future<void> _setup(
    CustomLintResolver resolver,
    CustomLintContext context,
  ) async {
    final registry = context.sharedState[_contextKey] = YXScopeRegistry();

    final watch = Stopwatch()..start();

    final unit = await resolver.getResolvedUnitResult();
    // Here we parse everything we need
    final result = await ResolvedYXScopeResult.from([unit.unit]);

    watch.stop();
    print(': ${watch.elapsedMilliseconds}ms');

    context.addPostRunCallback(() {
      // Here we store the parsed data and notify subscribers
      registry.run(result);
    });
  }
}
