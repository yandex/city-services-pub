import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:yx_scope_linter/src/lints/avoid_async_dep_child_scope.dart';
import 'package:yx_scope_linter/src/lints/consider_dep_suffix.dart';
import 'package:yx_scope_linter/src/lints/dep_cycle.dart';
import 'package:yx_scope_linter/src/lints/pass_async_lifecycle_in_initialize_queue.dart';
import 'package:yx_scope_linter/src/lints/use_async_dep_for_async_lifecycle.dart';

import 'lints/final_dep.dart';

class YXScopedLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [
        FinalDep(),
        DepCycle(),
        ConsiderDepSuffix(),
        PassAsyncLifecycleInInitializeQueue(),
        UseAsyncDepForAsyncLifecycle(),
        AvoidChildScopeInInitializeQueue(),
      ];
}
