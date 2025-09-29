import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_scope/yx_scope.dart';
import 'package:yx_scope_flutter/yx_scope_flutter.dart' as yx_flutter;

import 'test_utils.dart';

class TestScopeStateHolder extends ScopeHolder<TestScopeContainer> {
  TestScopeStateHolder();

  @override
  TestScopeContainer createContainer() => TestScopeContainer();
}

class TestScopeContainer extends ScopeContainer {}

class TestListenerApp<T> extends StatelessWidget {
  final ScopeStateHolder<T?> holder;
  final CounterProvider listenerCounter;
  final Widget child;

  const TestListenerApp({
    super.key,
    required this.holder,
    required this.listenerCounter,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => yx_flutter.ScopeProvider<T>(
        holder: holder,
        child: MaterialApp(
          home: yx_flutter.ScopeListener<T>(
            listener: (context, scope) {
              listenerCounter.count++;
            },
            child: child,
          ),
        ),
      );
}

void main() {
  testWidgets('Listener is not called after disposal', (tester) async {
    final holder = TestScopeStateHolder();
    final counter = CounterProvider(0);

    await tester.pumpWidget(TestListenerApp<TestScopeContainer>(
      holder: holder,
      listenerCounter: counter,
      child: const SizedBox.shrink(),
    ));

    await tester.pumpWidget(const SizedBox.shrink()); // Dispose widget tree
    await holder.create();

    expect(counter.count, 0);
  });

  testWidgets('Listener handles holder change correctly', (tester) async {
    final holder1 = TestScopeStateHolder();
    final holder2 = TestScopeStateHolder();
    final counter = CounterProvider(0);

    await tester.pumpWidget(TestListenerApp<TestScopeContainer>(
      holder: holder1,
      listenerCounter: counter,
      child: const SizedBox.shrink(),
    ));

    await holder1.create();
    expect(counter.count, 1);

    // Change holder
    await tester.pumpWidget(TestListenerApp<TestScopeContainer>(
      holder: holder2,
      listenerCounter: counter,
      child: const SizedBox.shrink(),
    ));

    await holder2.create();
    expect(counter.count, 2);
  });
}
