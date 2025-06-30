import 'package:yx_scope/yx_scope.dart';

class SomeScope extends BaseScopeContainer {
  late final syncDep = dep(() => '1');

  // expect_lint: use_async_dep_for_async_lifecycle
  late final shouldBeAsyncDep = dep(() => AsyncLifecycleButSyncDeclaration());
}

class AsyncLifecycleButSyncDeclaration implements AsyncLifecycle {
  const AsyncLifecycleButSyncDeclaration();

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}
}
