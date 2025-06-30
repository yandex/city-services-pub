import 'package:yx_scope/yx_scope.dart';

class SomeScope extends BaseScopeContainer {
  static const someConstant = 'some_constant';

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {lateFinalAsyncDep}
      ];

  var someRandomField = 'random_field';

  late final lateFinalDep = dep(() => '1');

  // expect_lint: final_dep
  late var finalDep = dep(() => '2');

  late final lateFinalAsyncDep = asyncDep(() => SomeAsyncDep());

  // expect_lint: final_dep, pass_async_lifecycle_in_initialize_queue
  late var lateAsyncDep = asyncDep(() => SomeAsyncDep());

  // expect_lint: final_dep, pass_async_lifecycle_in_initialize_queue
  late AsyncDep<SomeAsyncDep> explicitTypeLateAsyncDep =
      asyncDep(() => SomeAsyncDep());

  // expect_lint: pass_async_lifecycle_in_initialize_queue
  late final AsyncDep<SomeAsyncDep> explicitTypeLateFinalAsyncDep =
      asyncDep(() => SomeAsyncDep());

  // expect_lint: final_dep, pass_async_lifecycle_in_initialize_queue
  late var lateRawAsyncDep =
      rawAsyncDep(() => '3', init: (dep) async {}, dispose: (dep) async {});

  // expect_lint: pass_async_lifecycle_in_initialize_queue
  late final lateFinalRawAsyncDep =
      rawAsyncDep(() => '4', init: (dep) async {}, dispose: (dep) async {});

  void someMethod() {}
}

class SomeAsyncDep implements AsyncLifecycle {
  const SomeAsyncDep();

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}
}
