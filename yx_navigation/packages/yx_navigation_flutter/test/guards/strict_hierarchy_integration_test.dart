// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/config/state_manager_configuration.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(registerFallbacks);

  group('StrictHierarchyGuard integration', () {
    test('allows navigation to declared child in strict mode', () {
      // arrange
      const parentRoute = YxRoute(id: 'parent');
      const childRoute = YxRoute(id: 'child');
      final childDeclaration = RouteDeclaration.routeBuilder(
        route: childRoute,
        routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
      );
      final parentDeclaration = RouteDeclaration.strict(
        route: parentRoute,
        routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
        declarations: [childDeclaration],
      );
      final schema = makeSchema(
        initialNodeBuilder: (node) => node..add(parentRoute.toMutableNode()),
        declarations: [parentDeclaration],
      );
      final config = schema.build();
      addTearDown(config.dispose);
      final actualParentController = NavigationController.node(
        stateManager: config.routerDelegate.stateManager,
        nodeResolver: const RouteNodeResolver.id(route: parentRoute),
      )

        // act
        ..push(childRoute);

      // assert
      expect(
        actualParentController.state?.findByRoute(childRoute),
        isNotNull,
      );
    });

    test('allows any child when parent is not strict', () {
      // arrange
      const parentRoute = YxRoute(id: 'parent');
      const anyChild = YxRoute(id: 'any-child');
      final parentDeclaration = RouteDeclaration.routeBuilder(
        route: parentRoute,
        routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
      );
      final schema = makeSchema(
        initialNodeBuilder: (node) => node..add(parentRoute.toMutableNode()),
        declarations: [parentDeclaration],
      );
      final config = schema.build();
      addTearDown(config.dispose);
      final actualNavigator = config.routerDelegate.stateManager

        // act
        ..push(anyChild);

      // assert
      expect(actualNavigator.state.findByRoute(anyChild), isNotNull);
    });

    test('blocks push to undeclared child and reports via guard observer', () {
      // arrange
      const parentRoute = YxRoute(id: 'parent');
      const undeclaredRoute = YxRoute(id: 'undeclared-child');
      final parentDeclaration = RouteDeclaration.strict(
        route: parentRoute,
        routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
        declarations: const [],
      );
      final actualGuardObserver = GuardObserverMock();
      final schema = makeSchema(
        initialNodeBuilder: (node) => node..add(parentRoute.toMutableNode()),
        declarations: [parentDeclaration],
      );
      final config = schema.build(
        stateManagerConfiguration: StateManagerConfiguration(
          guardObserver: actualGuardObserver,
        ),
      );
      addTearDown(config.dispose);
      final actualParentController = NavigationController.node(
        stateManager: config.routerDelegate.stateManager,
        nodeResolver: const RouteNodeResolver.id(route: parentRoute),
      )

        // act
        ..push(undeclaredRoute);

      // assert: undeclared route is absent.
      expect(
        actualParentController.state?.findByRoute(undeclaredRoute),
        isNull,
      );

      final verificationResult = verify(
        () => actualGuardObserver.onGuardError(
          captureAny(),
          captureAny(),
          captureAny(),
          any(),
          captureAny(),
        ),
      );
      expect(
        verificationResult.captured.first,
        isA<RouteNode>().having(
          (e) => e.route.id,
          'route',
          equals('root'),
        ),
      );
      expect(
        verificationResult.captured[1],
        isA<RouteNode>().having(
          (e) =>
              e.findByRoute(parentRoute)?.children.map((e) => e.route).toList(),
          'undeclared route in parent',
          contains(undeclaredRoute),
        ),
      );
      expect(verificationResult.captured[2], isA<StateError>());
      expect(verificationResult.captured[3], isA<StrictHierarchyGuard>());
    });

    test('blocks mutate that adds undeclared child in strict mode', () {
      // arrange
      const parentRoute = YxRoute(id: 'parent');
      const undeclaredRoute = YxRoute(id: 'undeclared-child');
      final parentDeclaration = RouteDeclaration.strict(
        route: parentRoute,
        routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
        declarations: const [],
      );
      final actualGuardObserver = GuardObserverMock();
      final schema = makeSchema(
        initialNodeBuilder: (node) => node..add(parentRoute.toMutableNode()),
        declarations: [parentDeclaration],
      );
      final config = schema.build(
        stateManagerConfiguration: StateManagerConfiguration(
          guardObserver: actualGuardObserver,
        ),
      );
      addTearDown(config.dispose);
      final actualRootNavigator = config.routerDelegate.stateManager

        // act
        ..mutate((state) {
          final parent = state.findByRoute(parentRoute);
          if (parent != null) {
            parent.add(undeclaredRoute.toMutableNode());
          }
          return state;
        });

      // assert
      final parentNode = actualRootNavigator.state.findByRoute(parentRoute);
      expect(
        parentNode?.children.map((e) => e.route).toList(),
        isNot(contains(undeclaredRoute)),
      );

      final verificationResult = verify(
        () => actualGuardObserver.onGuardError(
          captureAny(),
          captureAny(),
          captureAny(),
          any(),
          captureAny(),
        ),
      );
      expect(
        verificationResult.captured.first,
        isA<RouteNode>().having(
          (e) => e.route.id,
          'route',
          equals('root'),
        ),
      );
      expect(
        verificationResult.captured[1],
        isA<RouteNode>().having(
          (e) =>
              e.findByRoute(parentRoute)?.children.map((e) => e.route).toList(),
          'undeclared route in parent',
          contains(undeclaredRoute),
        ),
      );
      expect(verificationResult.captured[2], isA<StateError>());
      expect(verificationResult.captured[3], isA<StrictHierarchyGuard>());
    });

    test(
      'rejects undeclared child when parent has explicit empty declarations',
      () {
        // arrange
        const parentRoute = YxRoute(id: 'parent');
        const undeclaredChild = YxRoute(id: 'undeclared-child');
        final parentDeclaration = RouteDeclaration.strict(
          route: parentRoute,
          routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
          declarations: const [],
        );
        final undeclaredChildDeclaration = RouteDeclaration.routeBuilder(
          route: undeclaredChild,
          routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
        );
        final actualGuardObserver = GuardObserverMock();
        final schema = makeSchema(
          initialNodeBuilder: (node) => node..add(parentRoute.toMutableNode()),
          declarations: [parentDeclaration, undeclaredChildDeclaration],
        );
        final config = schema.build(
          stateManagerConfiguration: StateManagerConfiguration(
            guardObserver: actualGuardObserver,
          ),
        );
        addTearDown(config.dispose);
        final actualParentController = NavigationController.node(
          stateManager: config.routerDelegate.stateManager,
          nodeResolver: const RouteNodeResolver.id(route: parentRoute),
        )

          // act
          ..push(undeclaredChild);

        // assert
        expect(
          actualParentController.state?.findByRoute(undeclaredChild),
          isNull,
        );
        final verificationResult = verify(
          () => actualGuardObserver.onGuardError(
            captureAny(),
            captureAny(),
            captureAny(),
            any(),
            captureAny(),
          ),
        );
        expect(verificationResult.captured[2], isA<StateError>());
        expect(verificationResult.captured[3], isA<StrictHierarchyGuard>());
      },
    );

    group('validates every instance of the strict route in the tree', () {
      // Shared arrange: two instances of the same strict route under a root,
      // with a single declared child. Each scenario mutates the tree to
      // different configurations of the two instances and asserts the guard.
      const strictRoute = YxRoute(id: 'strict-parent');
      const declaredChild = YxRoute(id: 'declared-child');
      const rootRoute = YxRoute(id: 'root');

      ({
        BaseStateManager navigator,
        GuardObserverMock observer,
      }) buildScenario() {
        final declaredChildDeclaration = RouteDeclaration.routeBuilder(
          route: declaredChild,
          routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
        );
        final strictDeclaration = RouteDeclaration.strict(
          route: strictRoute,
          routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
          declarations: [declaredChildDeclaration],
        );
        final rootDeclaration = RouteDeclaration.routeBuilder(
          route: rootRoute,
          routeBuilder: RouteBuilder.widget(builder: (_, __) => Container()),
          declarations: [strictDeclaration],
        );
        final observer = GuardObserverMock();
        final schema = makeSchema(
          initialNodeBuilder: (node) => node..add(rootRoute.toMutableNode()),
          declarations: [rootDeclaration],
        );
        final config = schema.build(
          stateManagerConfiguration: StateManagerConfiguration(
            guardObserver: observer,
          ),
        );
        addTearDown(config.dispose);
        return (
          navigator: config.routerDelegate.stateManager,
          observer: observer,
        );
      }

      test(
        'first instance valid, second instance with undeclared child — only '
        'the second instance is rejected',
        () {
          // arrange
          const undeclaredChild = YxRoute(id: 'undeclared-1');
          final scenario = buildScenario();

          // act
          scenario.navigator.mutate((state) {
            final root = state.toMutable();
            final instance1 = strictRoute.toMutableNode()
              ..add(declaredChild.toNode());
            final instance2 = strictRoute.toMutableNode()
              ..add(undeclaredChild.toNode());
            root
              ..clearChildren()
              ..add(instance1)
              ..add(instance2);
            return root;
          });

          // assert
          verify(
            () => scenario.observer.onGuardError(
              captureAny(),
              captureAny(),
              captureAny(),
              any(),
              captureAny(),
            ),
          ).called(1);
          expect(scenario.navigator.state.findByRoute(undeclaredChild), isNull);
        },
      );

      test(
        'first instance with undeclared child, second instance valid — only '
        'the first instance is rejected',
        () {
          // arrange
          const undeclaredChild = YxRoute(id: 'undeclared-2');
          final scenario = buildScenario();

          // act
          scenario.navigator.mutate((state) {
            final root = state.toMutable();
            final instance1 = strictRoute.toMutableNode()
              ..add(undeclaredChild.toNode());
            final instance2 = strictRoute.toMutableNode()
              ..add(declaredChild.toNode());
            root
              ..clearChildren()
              ..add(instance1)
              ..add(instance2);
            return root;
          });

          // assert
          verify(
            () => scenario.observer.onGuardError(
              captureAny(),
              captureAny(),
              captureAny(),
              any(),
              captureAny(),
            ),
          ).called(1);
          expect(scenario.navigator.state.findByRoute(undeclaredChild), isNull);
        },
      );

      test(
        'both instances valid — no guard errors, both remain in the tree',
        () {
          // arrange
          final scenario = buildScenario();

          // act
          scenario.navigator.mutate((state) {
            final root = state.toMutable();
            final instance1 = strictRoute.toMutableNode()
              ..add(declaredChild.toNode());
            final instance2 = strictRoute.toMutableNode()
              ..add(declaredChild.toNode());
            root
              ..clearChildren()
              ..add(instance1)
              ..add(instance2);
            return root;
          });

          // assert
          verifyNever(
            () => scenario.observer.onGuardError(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
          final actualStrictInstances = <RouteNode>[];
          scenario.navigator.state.traverse((node) {
            if (node.route == strictRoute) {
              actualStrictInstances.add(node);
            }
            return false;
          });
          expect(actualStrictInstances, hasLength(2));
          for (final instance in actualStrictInstances) {
            expect(instance.children, hasLength(1));
            expect(instance.children.first.route, equals(declaredChild));
          }
        },
      );
    });
  });
}
