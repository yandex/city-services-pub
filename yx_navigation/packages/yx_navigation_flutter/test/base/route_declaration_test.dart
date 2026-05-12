import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_builder_declaration.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_strict_declaration.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('RouteDeclaration', () {
    test(
        'routeBuilder factory builds a RouteBuilderDeclaration with empty '
        'child declarations by default', () {
      // arrange
      const actualRoute = YxRoute(id: 'home');
      final actualBuilder = RouteBuilder<Object?>.widget(
        builder: (context, node) => const SizedBox.shrink(),
      );

      // act
      final actualDeclaration = RouteDeclaration.routeBuilder(
        route: actualRoute,
        routeBuilder: actualBuilder,
      );

      // assert: runtime type is the public wrapper (consumers pattern-match
      // on it) and the `declarations` default is a locked public contract.
      expect(actualDeclaration, isA<RouteBuilderDeclaration>());
      expect(actualDeclaration.declarations, isEmpty);
    });

    test('strict factory builds a RouteStrictDeclaration', () {
      // arrange
      const expectedRoute = YxRoute(id: 'root');
      const declaredChild = YxRoute(id: 'child');
      final expectedBuilder = RouteBuilder<Object?>.widget(
        builder: (context, node) => const SizedBox.shrink(),
      );
      final childDeclaration = RouteDeclaration.routeBuilder(
        route: declaredChild,
        routeBuilder: expectedBuilder,
      );

      // act
      final actualDeclaration = RouteDeclaration.strict(
        route: expectedRoute,
        routeBuilder: expectedBuilder,
        declarations: [childDeclaration],
      );

      // assert: contract — wrapper type and declarations are exposed.
      expect(actualDeclaration, isA<RouteStrictDeclaration>());
      expect(actualDeclaration.route, equals(expectedRoute));
      expect(actualDeclaration.declarations, hasLength(1));
    });

    test(
        'strict declaration enforces child hierarchy via the state manager: '
        'pushing an undeclared child results in a StateError', () {
      // arrange: build a strict declaration for a parent route with a single
      // declared child.
      const parentRoute = YxRoute(id: 'strict_parent');
      const declaredChildRoute = YxRoute(id: 'declared_child');
      const undeclaredChildRoute = YxRoute(id: 'undeclared_child');
      final declaration = RouteDeclaration.strict(
        route: parentRoute,
        routeBuilder: RouteBuilder<Object?>.widget(
          builder: (context, node) => const SizedBox.shrink(),
        ),
        declarations: [
          RouteDeclaration.routeBuilder(
            route: declaredChildRoute,
            routeBuilder: RouteBuilder<Object?>.widget(
              builder: (context, node) => const SizedBox.shrink(),
            ),
          ),
        ],
      ) as RouteStrictDeclaration;

      // arrange: a state manager starting with the declared child only.
      final initialNode = makeNode(
        route: parentRoute,
        children: [makeNode(route: declaredChildRoute)],
      );
      final stateManager = RouteNodeStateManager(
        routeNode: initialNode,
        routeNodeGuard: declaration.buildGuards().first,
      );

      // act/assert: attempting to mutate to include an undeclared child
      // bubbles the StateError up from StrictHierarchyGuard.
      expect(
        () => stateManager.mutate(
          (node) => makeNode(
            route: parentRoute,
            children: [
              makeNode(route: declaredChildRoute),
              makeNode(route: undeclaredChildRoute),
            ],
          ).toMutable(),
        ),
        throwsStateError,
      );
    });

    test(
        'indexedStack declaration automatically synchronises children '
        'with declarations (missing children are added, extras dropped)', () {
      // arrange: indexed-stack parent with two declared children (tabs).
      const parentRoute = YxRoute(id: 'tabs');
      const tabAlphaRoute = YxRoute(id: 'tab_alpha');
      const tabBetaRoute = YxRoute(id: 'tab_beta');
      const undeclaredRoute = YxRoute(id: 'not_a_tab');
      final declaration = RouteDeclaration.indexedStack(
        route: parentRoute,
        routeBuilder: RouteBuilder.indexed<Object?>(
          indexedBuilder: (context, node, child, controller) => child,
        ),
        declarations: [
          RouteDeclaration.routeBuilder(
            route: tabAlphaRoute,
            routeBuilder: RouteBuilder<Object?>.widget(
              builder: (context, node) => const SizedBox.shrink(),
            ),
          ),
          RouteDeclaration.routeBuilder(
            route: tabBetaRoute,
            routeBuilder: RouteBuilder<Object?>.widget(
              builder: (context, node) => const SizedBox.shrink(),
            ),
          ),
        ],
      );

      // arrange: state manager seeded with children that do NOT match the
      // declared set (missing `tab_beta`, extra `not_a_tab`).
      final initialNode = makeNode(
        route: parentRoute,
        children: [
          makeNode(route: tabAlphaRoute),
          makeNode(route: undeclaredRoute),
        ],
      );
      final stateManager = RouteNodeStateManager(
        routeNode: initialNode,
        routeNodeGuard: declaration.buildGuards().first,
      )
        // act: triggering a mutation causes the indexed-stack guard to
        // redirect to a corrected tree with declared children in declared
        // order.
        ..mutate((node) => node);

      // assert
      final childrenAfter =
          stateManager.state.children.map((c) => c.route).toList();
      expect(childrenAfter, equals(const [tabAlphaRoute, tabBetaRoute]));
      expect(childrenAfter.contains(undeclaredRoute), isFalse);
    });
  });
}
