import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_scope/yx_scope.dart' as yx_scope;
import 'package:yx_scope_flutter/yx_scope_flutter.dart';

import 'test_utils.dart';

class AppScopeContainer extends yx_scope.ScopeContainer {
  late final counterProviderDep = dep(() => CounterProvider(0));
}

class AppScopeHolder extends yx_scope.ScopeHolder<AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}

class ScopeBuilderApp extends StatefulWidget {
  const ScopeBuilderApp({super.key});

  @override
  State<ScopeBuilderApp> createState() => _AppState();
}

class _AppState extends State<ScopeBuilderApp> {
  bool showSecondApp = false;
  final _appScopeHolder = AppScopeHolder();
  final _secondAppScopeHolder = AppScopeHolder();

  @override
  void initState() {
    super.initState();
    _appScopeHolder.create();
    _secondAppScopeHolder.create();
  }

  @override
  void dispose() {
    _secondAppScopeHolder.drop();
    _appScopeHolder.drop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopeProvider(
      holder: _appScopeHolder,
      child: ScopeBuilderTestWidget(
        secondAppScopeHolder: _secondAppScopeHolder,
      ),
    );
  }
}

class ScopeBuilderTestWidget extends StatefulWidget {
  final AppScopeHolder secondAppScopeHolder;

  const ScopeBuilderTestWidget({
    super.key,
    required this.secondAppScopeHolder,
  });

  @override
  State<ScopeBuilderTestWidget> createState() => _ScopeBuilderTestWidgetState();
}

class _ScopeBuilderTestWidgetState extends State<ScopeBuilderTestWidget> {
  bool showSecondApp = false;

  @override
  Widget build(BuildContext context) {
    return ScopeBuilder<AppScopeContainer>.withPlaceholder(
      // Replace ScopeHolder that ScopeBuilder will take from
      // ScopeProvider as InheritedWidget to another ScopeHolder
      holder: showSecondApp ? widget.secondAppScopeHolder : null,
      builder: (context, appScope) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(appScope.counterProviderDep.get.count.toString()),
                  ElevatedButton(
                    onPressed: () {
                      // Add 1 to appScope that is currently stored in
                      // ScopeBuilder's ScopeHolder and change ScopeBuilder's
                      // ScopeHolder to another one
                      // Therefore value on the screen should increase by 1
                      // every two taps
                      setState(() {
                        appScope.counterProviderDep.get.count += 1;
                        showSecondApp = !showSecondApp;
                      });
                    },
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ScopeListenerTestApp extends StatelessWidget {
  final AppScopeHolder appScopeHolder;
  final CounterProvider counter;

  const ScopeListenerTestApp({
    super.key,
    required this.appScopeHolder,
    required this.counter,
  });

  @override
  Widget build(BuildContext context) {
    return ScopeListener<AppScopeContainer>(
      holder: appScopeHolder,
      listener: (BuildContext context, AppScopeContainer? scope) {
        counter.count++;
      },
      child: const SizedBox(),
    );
  }
}

void main() {
  testWidgets(
      'Don\'t throw exception when change ScopeBuilder\'s holder using setState',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ScopeBuilderApp());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    final dynamic exception = tester.takeException();
    expect(exception, isNull);
  });

  testWidgets('Check that ScopeBuilder subscribes to correct holder',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ScopeBuilderApp());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect((find.byType(Text).evaluate().single.widget as Text).data, '0');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect((find.byType(Text).evaluate().single.widget as Text).data, '1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect((find.byType(Text).evaluate().single.widget as Text).data, '1');
  });

  testWidgets(
      'Invoke ScopeListener\'s listen method only when scope state changes',
      (WidgetTester tester) async {
    final appScopeHolder = AppScopeHolder();
    final counter = CounterProvider(0);
    await tester.pumpWidget(ScopeListenerTestApp(
      appScopeHolder: appScopeHolder,
      counter: counter,
    ));
    expect(counter.count, 0);
    appScopeHolder.create();
    expect(counter.count, 1);
  });
}
