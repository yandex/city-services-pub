import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/base/route_declaration_resolver.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

RouteDeclaration _leaf(YxRoute route) => RouteDeclaration.routeBuilder(
      route: route,
      routeBuilder: RouteBuilder<Object?>.widget(
        builder: (context, node) => const SizedBox.shrink(),
      ),
    );

void main() {
  setUpAll(registerFallbacks);

  group('RouteDeclarationResolver', () {
    test('resolves a declaration for the node route', () {
      // arrange
      const expectedRoute = YxRoute(id: 'details');
      final expectedDeclaration = _leaf(expectedRoute);
      final actualResolver = RouteDeclarationResolver(
        declarations: [expectedDeclaration],
      );

      // act
      final actualResult =
          actualResolver.resolve(makeNode(route: expectedRoute));

      // assert
      expect(actualResult, same(expectedDeclaration));
    });

    test('returns null when route is not declared', () {
      // arrange
      const declaredRoute = YxRoute(id: 'home');
      final actualResolver = RouteDeclarationResolver(
        declarations: [_leaf(declaredRoute)],
      );

      // act
      final actualResult = actualResolver.resolve(
        makeNode(route: makeRoute(id: 'missing')),
      );

      // assert
      expect(actualResult, isNull);
    });

    test('throws AssertionError when the same route key is declared twice', () {
      // arrange
      const duplicatedRoute = YxRoute(id: 'dup');

      // act/assert: buildDeclarationsMap asserts that a given route key is
      // not added twice.
      expect(
        () => RouteDeclarationResolver(
          declarations: [
            _leaf(duplicatedRoute),
            _leaf(duplicatedRoute),
          ],
        ),
        throwsAssertionError,
      );
    });

    test('indexes nested declarations recursively', () {
      // arrange
      const childRoute = YxRoute(id: 'child');
      const rootRoute = YxRoute(id: 'root');
      final rootDeclaration = RouteDeclaration.routeBuilder(
        route: rootRoute,
        routeBuilder: RouteBuilder<Object?>.widget(
          builder: (context, node) => const SizedBox.shrink(),
        ),
        declarations: [_leaf(childRoute)],
      );
      final actualResolver = RouteDeclarationResolver(
        declarations: [rootDeclaration],
      );

      // act
      final actualChildResult = actualResolver.resolve(
        makeNode(route: childRoute),
      );

      // assert
      expect(actualChildResult, isNotNull);
      expect(actualChildResult!.route, equals(childRoute));
    });
  });
}
