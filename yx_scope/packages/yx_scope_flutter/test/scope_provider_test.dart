import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_scope/yx_scope.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import 'test_utils.dart';

class MyAppNoProvider extends MaterialApp {
  const MyAppNoProvider({
    required Widget home,
    Key? key,
  }) : super(key: key, home: home);
}

class MyApp<T> extends StatelessWidget {
  final Widget home;
  final ScopeStateHolder<T?> holder;
  const MyApp({super.key, required this.home, required this.holder});

  @override
  Widget build(BuildContext context) => ScopeProvider<T>(
        holder: holder,
        child: MaterialApp(home: home),
      );
}

class TestScopeStateHolder extends ScopeHolder<TestScopeContainer> {
  TestScopeStateHolder();

  @override
  TestScopeContainer createContainer() => TestScopeContainer();
}

class TestScopeContainer extends ScopeContainer {}

class ScopeWidget<T> extends StatelessWidget {
  final CounterProvider? buildsCounter;
  const ScopeWidget({
    super.key,
    this.buildsCounter,
  });

  @override
  Widget build(BuildContext context) {
    final _ = ScopeProvider.of<T>(context);
    buildsCounter?.count++;
    return Container();
  }
}

class NoScopeWidget extends StatelessWidget {
  final CounterProvider? buildsCounter;

  const NoScopeWidget({
    super.key,
    required this.buildsCounter,
  });

  @override
  Widget build(BuildContext context) {
    buildsCounter?.count++;
    return Container();
  }
}

abstract class SomeScope {}

class SomeScopeContainer extends ScopeContainer implements SomeScope {}

class SomeScopeHolder extends ScopeHolder<SomeScopeContainer> {
  @override
  SomeScopeContainer createContainer() => SomeScopeContainer();
}

void main() {
  testWidgets(
      'Throw exception if the context you used comes from a widget above the ScopeProvider',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        const MyAppNoProvider(home: ScopeWidget<TestScopeContainer>()));
    final dynamic exception = tester.takeException();
    const expectedMessage = '''
        ScopeProvider.of() called with a context that does not contain a TestScopeContainer.
        No ancestor could be found starting from the context that was passed to ScopeProvider.of<TestScopeContainer>().

        This can happen if the context you used comes from a widget above the ScopeProvider.

        The context used was: ScopeWidget<TestScopeContainer>(dirty)
''';
    expect((exception as FlutterScopeError).message, expectedMessage);
  });

  testWidgets(
      'Don\'t throw exception if the context you used comes from a widget further down the ScopeProvider',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp<TestScopeContainer>(
      home: const ScopeWidget<TestScopeContainer>(),
      holder: TestScopeStateHolder(),
    ));
    final dynamic exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets(
      'Don\'t throw exception if you use an interface in the ScopeProvider.of<SomeScope>() method and inject the same interface in a ScopeProvider<SomeScope>',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp<SomeScope>(
      home: const ScopeWidget<SomeScope>(),
      holder: SomeScopeHolder(),
    ));
    final dynamic exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets(
      'Don\'t throw exception if you use a SomeScopeContainer that implemetns SomeScope in ScopeProvider.of<SomeScope> and inject the same class into the ScopeProvider<SomeScopeContainer>',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp<SomeScopeContainer>(
      home: const ScopeWidget<SomeScopeContainer>(),
      holder: SomeScopeHolder(),
    ));
    final dynamic exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets(
      'Don\'t throw exception if you dont explicitly write the interface SomeScope into the type for ScopeProvider and use SomeScopeContainer that implements SomeScopeContainer',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      home: const ScopeWidget<SomeScopeContainer>(),
      holder: SomeScopeHolder(),
    ));
    final dynamic exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets(
      'Throw exception if you use a SomeScope interface in ScopeProvider.of<SomeScope> and inject SomeScopeContainer that implements SomeScope in ScopeProvider<SomeScopeContainer>',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp<SomeScopeContainer>(
      home: const ScopeWidget<SomeScope>(),
      holder: SomeScopeHolder(),
    ));
    final dynamic exception = tester.takeException();
    const expectedMessage = '''
        ScopeProvider.of() called with a context that does not contain a SomeScope.
        No ancestor could be found starting from the context that was passed to ScopeProvider.of<SomeScope>().

        This can happen if the context you used comes from a widget above the ScopeProvider.

        The context used was: ScopeWidget<SomeScope>(dirty)
''';
    expect((exception as FlutterScopeError).message, expectedMessage);
  });

  testWidgets(
      'Throw exception if you use SomeScopeContainer that implements SomeScope in ScopeProvider.of<SomeScopeContainer>() method and inject SomeScope interface in ScopeProvider<SomeScope> ',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp<SomeScope>(
      home: const ScopeWidget<SomeScopeContainer>(),
      holder: SomeScopeHolder(),
    ));
    final dynamic exception = tester.takeException();
    const expectedMessage = '''
        ScopeProvider.of() called with a context that does not contain a SomeScopeContainer.
        No ancestor could be found starting from the context that was passed to ScopeProvider.of<SomeScopeContainer>().

        This can happen if the context you used comes from a widget above the ScopeProvider.

        The context used was: ScopeWidget<SomeScopeContainer>(dirty)
''';
    expect((exception as FlutterScopeError).message, expectedMessage);
  });

  testWidgets(
      'Scope updates reflect in subtree rebuilds only for children which have been subscribed to Scope via ScopeProvider.of',
      (WidgetTester tester) async {
    final holder = SomeScopeHolder();
    final scopeBuildsCounter = CounterProvider(0);
    final noScopeBuildsCounter = CounterProvider(0);
    await tester.pumpWidget(MyApp(
      holder: holder,
      home: Stack(
        children: [
          ScopeWidget<SomeScopeContainer>(buildsCounter: scopeBuildsCounter),
          NoScopeWidget(buildsCounter: noScopeBuildsCounter),
        ],
      ),
    ));

    await tester.pumpAndSettle();
    expect(scopeBuildsCounter.count, 1);
    expect(noScopeBuildsCounter.count, 1);

    await holder.create();
    await tester.pumpAndSettle();

    expect(scopeBuildsCounter.count, 2);
    expect(noScopeBuildsCounter.count, 1);

    await holder.drop();
    await tester.pumpAndSettle();

    expect(scopeBuildsCounter.count, 3);
    expect(noScopeBuildsCounter.count, 1);
  });
}
