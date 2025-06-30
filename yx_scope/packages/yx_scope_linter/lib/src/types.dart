import 'package:custom_lint_builder/custom_lint_builder.dart';

const baseScopeContainerType = TypeChecker.fromName(
  'BaseScopeContainer',
  packageName: 'yx_scope',
);

const depValueType = TypeChecker.fromName(
  'Dep',
  packageName: 'yx_scope',
);
const asyncDepValueType = TypeChecker.fromName(
  'AsyncDep',
  packageName: 'yx_scope',
);

const asyncLifecycleType = TypeChecker.fromName(
  'AsyncLifecycle',
  packageName: 'yx_scope',
);

const childScopeHolderValueType = TypeChecker.fromName(
  'ChildScopeHolder',
  packageName: 'yx_scope',
);

const scopeContainerValueType = TypeChecker.fromName(
  'ScopeContainer',
  packageName: 'yx_scope',
);

const anyDepValueTypes = TypeChecker.any([depValueType, asyncDepValueType]);

const scopeModuleType = TypeChecker.fromName(
  'ScopeModule',
  packageName: 'yx_scope',
);
