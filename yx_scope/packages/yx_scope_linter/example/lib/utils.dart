import 'package:example/dep_cycle.dart';
import 'package:yx_scope/yx_scope.dart';

class UtilsScopeModule extends ScopeModule<SomeScope> {
  UtilsScopeModule(super.container);

  late final some7Dep = rawAsyncDep(
    () {
      return container.createSome4Dep();
    },
    init: (dep) async => dep.init(),
    dispose: (dep) async => dep.dispose(),
  );

  late final Dep<SomeUtilsDep> someUtilsDep = dep(() => _createSomeUtilsDep());

  SomeUtilsDep _createSomeUtilsDep() => SomeUtilsDep(container.some7Dep.get);
}

class SomeUtilsDep {
  final SomeDep7 some7;

  SomeUtilsDep(this.some7);
}
