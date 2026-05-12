import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/base/route_declaration_resolver.dart';
import 'package:yx_navigation_flutter/src/base/route_node_builder.dart';
import 'package:yx_navigation_flutter/src/compatibility/navigator_compatibility_overrides.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

RouteDeclaration _declaration(YxRoute route) => RouteDeclaration.routeBuilder(
      route: route,
      routeBuilder: RouteBuilder<Object?>.widget(
        builder: (context, node) => Text('route:${node.route.id}'),
      ),
    );

void main() {
  setUpAll(registerFallbacks);

  group('BaseRouteNodeBuilder', () {
    testWidgets('buildPages yields declaration-based page for declared route',
        (tester) async {
      // arrange
      const expectedRoute = YxRoute(id: 'home');
      final resolver = RouteDeclarationResolver(
        declarations: [_declaration(expectedRoute)],
      );
      final actualBuilder = BaseRouteNodeBuilder(
        routeDeclarationResolver: resolver,
      );
      Iterable<RoutePageEntry>? actualEntries;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              actualEntries = actualBuilder.buildPages(
                context,
                [makeNode(route: expectedRoute)],
              ).toList();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualEntries, isNotNull);
      expect(actualEntries, hasLength(1));
      expect(actualEntries!.first.routeNode.route, equals(expectedRoute));
      expect(actualEntries!.first.page, isA<Page<Object?>>());
    });

    testWidgets(
        'buildPages forwards the stored pageFactory for pageless (Navigator '
        '1.0 compatibility) nodes without consulting the declaration resolver',
        (tester) async {
      // arrange: a pageless node carries a pre-built page in its extra.
      const expectedPage = MaterialPage<Object?>(
        key: ValueKey('pageless_stub'),
        child: SizedBox.shrink(),
      );
      final pagelessNode = RouteNode.fromRoute(
        route: makeRoute(id: 'pageless_route'),
        extra: <String, Object?>{
          NavigatorCompatibilityOverrides.routeExtraKey:
              MaterialPageRoute<Object?>(
            builder: (_) => const SizedBox.shrink(),
          ),
          NavigatorCompatibilityOverrides.routeIdExtraKey: 'pageless_route',
          NavigatorCompatibilityOverrides.pageFactoryExtraKey: expectedPage,
        },
      );
      // resolver is intentionally empty — should not matter for pageless.
      final resolver = RouteDeclarationResolver(declarations: const []);
      final actualBuilder = BaseRouteNodeBuilder(
        routeDeclarationResolver: resolver,
      );
      Iterable<RoutePageEntry>? actualEntries;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              actualEntries = actualBuilder.buildPages(
                context,
                [pagelessNode],
              ).toList();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert: contract — pageless branch yields the stored Page as-is,
      // not a declaration-based nor a not-found page.
      expect(actualEntries, hasLength(1));
      expect(actualEntries!.first.page, same(expectedPage));
      expect(actualEntries!.first.routeNode, same(pagelessNode));
    });

    testWidgets('buildPages yields not-found page when route is undeclared',
        (tester) async {
      // arrange
      final resolver = RouteDeclarationResolver(declarations: const []);
      final actualBuilder = BaseRouteNodeBuilder(
        routeDeclarationResolver: resolver,
      );
      Iterable<RoutePageEntry>? actualEntries;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              actualEntries = actualBuilder.buildPages(
                context,
                [makeNode(route: makeRoute(id: 'unknown'))],
              ).toList();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualEntries, hasLength(1));
      expect(actualEntries!.first.page, isA<Page<Object?>>());
    });

    testWidgets('buildWidget returns declaration widget when matched',
        (tester) async {
      // arrange
      const expectedRoute = YxRoute(id: 'home');
      final resolver = RouteDeclarationResolver(
        declarations: [_declaration(expectedRoute)],
      );
      final actualBuilder = BaseRouteNodeBuilder(
        routeDeclarationResolver: resolver,
      );

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => actualBuilder.buildWidget(
              context,
              makeNode(route: expectedRoute),
            ),
          ),
        ),
      );

      // assert
      expect(find.text('route:home'), findsOneWidget);
    });
  });
}
