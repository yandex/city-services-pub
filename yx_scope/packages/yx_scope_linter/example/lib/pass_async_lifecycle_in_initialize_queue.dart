import 'package:yx_scope/yx_scope.dart';

class SomeScope extends BaseScopeContainer {
  static void someStaticMethod() {}

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {
          justMyString,
        }
      ];

  void someMethod() {}

  void someGenericMethod<T>() {}

  Future<void> someAsyncMethod() async {}

  String get someGetter => '';

  late final my1Dep = dep(() => '1');

  // expect_lint: consider_dep_suffix
  late final myDep2 = dep(() => '2');

  // expect_lint: consider_dep_suffix
  late final justMyString = asyncDep(() => SomeAsyncDep());

  // expect_lint: consider_dep_suffix, pass_async_lifecycle_in_initialize_queue
  late final rawAsync =
      rawAsyncDep(() => '4', init: (value) async {}, dispose: (value) async {});
}

class SomeAsyncDep implements AsyncLifecycle {
  const SomeAsyncDep();

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}
}
