import 'package:test/test.dart';
import 'package:yx_scope/yx_scope.dart';

class AppScopeContainer extends ScopeContainer {}

class AppScopeHolder extends ScopeHolder<AppScopeContainer> {
  AppScopeHolder({
    // ignore: deprecated_member_use_from_same_package
    List<ScopeListener>? scopeListeners,
    // ignore: deprecated_member_use_from_same_package
    List<DepListener>? depListeners,
    // ignore: deprecated_member_use_from_same_package
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          // ignore: deprecated_member_use_from_same_package
          scopeListeners: scopeListeners,
          scopeObservers: scopeObservers,
          // ignore: deprecated_member_use_from_same_package
          depListeners: depListeners,
          depObservers: depObservers,
          // ignore: deprecated_member_use_from_same_package
          asyncDepListeners: asyncDepListeners,
          asyncDepObservers: asyncDepObservers,
        );
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}

void main() {
  test(
      'Fail assert if both scopeListeners and scopeObservers passed to ScopeHolder',
      () {
    expect(
      () => AppScopeHolder(scopeListeners: [], scopeObservers: []),
      throwsA(
        isA<AssertionError>(),
      ),
    );
  });

  test(
      'Fail assert if both depListeners and depObservers passed to ScopeHolder',
      () {
    expect(
      () => AppScopeHolder(depListeners: [], depObservers: []),
      throwsA(
        isA<AssertionError>(),
      ),
    );
  });

  test(
      'Fail assert if both asyncDepListeners and asyncDepObservers passed to ScopeHolder',
      () {
    expect(
      () => AppScopeHolder(asyncDepListeners: [], asyncDepObservers: []),
      throwsA(
        isA<AssertionError>(),
      ),
    );
  });
}
