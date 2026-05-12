import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/late_initialization/late_init_route_declaration_resolver.dart';

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

  group('LateInitRouteDeclarationResolver', () {
    test('resolves initial declarations passed in constructor', () {
      // arrange
      const expectedRoute = YxRoute(id: 'root');
      final expectedDeclaration = _leaf(expectedRoute);
      final actualResolver = LateInitRouteDeclarationResolver(
        declarations: [expectedDeclaration],
      );

      // act
      final actualResult =
          actualResolver.resolve(makeNode(route: expectedRoute));

      // assert
      expect(actualResult, same(expectedDeclaration));
    });

    test('attaches new declarations and exposes them through resolve', () {
      // arrange
      const attachedRoute = YxRoute(id: 'plugin');
      final actualResolver = LateInitRouteDeclarationResolver();
      final expectedDeclaration = _leaf(attachedRoute);

      // act
      actualResolver.attach('plugin_a', [expectedDeclaration]);
      final actualResult =
          actualResolver.resolve(makeNode(route: attachedRoute));

      // assert
      expect(actualResult, same(expectedDeclaration));
    });

    test(
        'throws AssertionError when attach routes intersect the already '
        'registered routes', () {
      // arrange
      const sharedRoute = YxRoute(id: 'shared');
      final actualResolver = LateInitRouteDeclarationResolver(
        declarations: [_leaf(sharedRoute)],
      );

      // act/assert: attach() asserts that the new declarations do not
      // intersect the already-attached set.
      expect(
        () => actualResolver.attach('plugin', [_leaf(sharedRoute)]),
        throwsAssertionError,
      );
    });

    test('throws StateError when attaching same name twice', () {
      // arrange
      final actualResolver = LateInitRouteDeclarationResolver()
        ..attach('plugin', [_leaf(makeRoute(id: 'r1'))]);

      // act/assert
      expect(
        () => actualResolver.attach('plugin', [_leaf(makeRoute(id: 'r2'))]),
        throwsStateError,
      );
    });

    test('detach removes attached declarations from subsequent lookups', () {
      // arrange
      const attachedRoute = YxRoute(id: 'dropped');
      final actualResolver = LateInitRouteDeclarationResolver()
        ..attach('plugin', [_leaf(attachedRoute)])
        // act
        ..detach('plugin');
      final actualResult =
          actualResolver.resolve(makeNode(route: attachedRoute));

      // assert
      expect(actualResult, isNull);
    });

    test('throws StateError when detaching unknown name', () {
      // arrange
      final actualResolver = LateInitRouteDeclarationResolver();

      // act/assert
      expect(
        () => actualResolver.detach('missing'),
        throwsStateError,
      );
    });

    test('caches declarations across consecutive resolve calls', () {
      // arrange
      const expectedRoute = YxRoute(id: 'cached');
      final actualResolver = LateInitRouteDeclarationResolver(
        declarations: [_leaf(expectedRoute)],
      );

      // act
      final actualFirst =
          actualResolver.resolve(makeNode(route: expectedRoute));
      final actualSecond =
          actualResolver.resolve(makeNode(route: expectedRoute));

      // assert
      expect(actualFirst, same(actualSecond));
    });
  });
}
