import 'package:yx_scope/yx_scope.dart';

class SomeScope extends BaseScopeContainer {
  late final Dep<SomeDep0> some0Dep = dep(() => SomeDep0(some6Dep.get));

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {
          some2Dep,
          some4Dep,
          anysome2Dep,
        }
      ];

  // Some comment
  late final Dep<SomeDep0> some0WithCommentDep =
      dep(() => SomeDep0(some6Dep.get));

  // expect_lint: dep_cycle
  late final Dep<SomeDep1> some1Dep =
      dep(() => SomeDep1(some2: anysome2Dep.get));

  // Dependencies with same substring part sould not break dep cycle linter.
  late final some2Dep = asyncDep<SomeDep2>(() => SomeDep2(some3Dep.get));

  // expect_lint: dep_cycle
  late final anysome2Dep = asyncDep<SomeDep2>(() => SomeDep2(some3Dep.get));

  // expect_lint: dep_cycle
  late final Dep<SomeDep3> some3Dep = dep(() {
    final dep = _createSome3Dep();
    return dep;
  });

  SomeDep3 _createSome3Dep() {
    final some4 = some4Dep.get;
    return SomeDep3(some1Dep.get, some4: some4);
  }

  // expect_lint: dep_cycle
  late final some4Dep = rawAsyncDep(
    () {
      return _createSome4Dep();
    },
    init: (dep) async => dep.init(),
    dispose: (dep) async => dep.dispose(),
  );

  SomeDep4 _createSome4Dep() {
    return SomeDep4(some1Dep.get, some3Dep.get);
  }

  // expect_lint: dep_cycle
  late final Dep<SomeDep5> some5Dep = dep(_createSome5Dep);

  SomeDep5 _createSome5Dep() => SomeDep5(some6Dep.get);

  // expect_lint: dep_cycle
  late final some6Dep = dep(() => _createSome6Dep());

  SomeDep6 _createSome6Dep() => SomeDep6(some5Dep.get);
}

class SomeDep0 {
  final SomeDep6 some6;

  SomeDep0(this.some6);
}

class SomeDep1 {
  final SomeDep2 some2;

  const SomeDep1({required this.some2});
}

class SomeDep2 implements AsyncLifecycle {
  final SomeDep3 some3;

  const SomeDep2(this.some3);

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}
}

class SomeDep3 {
  final SomeDep1 some1;
  final SomeDep4 some4;

  const SomeDep3(this.some1, {required this.some4});
}

class SomeDep4 {
  final SomeDep1 some1;
  final SomeDep3 some3;

  const SomeDep4(this.some1, this.some3);

  void init() {}

  void dispose() {}
}

class SomeDep5 {
  final SomeDep6 some6;

  const SomeDep5(this.some6);
}

class SomeDep6 {
  final SomeDep5 some5;

  SomeDep6(this.some5);
}
