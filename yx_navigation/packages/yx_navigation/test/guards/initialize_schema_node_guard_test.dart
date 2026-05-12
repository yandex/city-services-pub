import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';
import 'package:yx_navigation/src/guard/default/initialize_schema_node_guard.dart';
import 'package:yx_navigation/src/guard/guard_context.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';

import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('InitializeSchemaNodeGuard', () {
    const rootRoute = YxRoute(id: 'root');
    const schemaRoute = YxRoute(id: 'schema');
    const childRoute = YxRoute(id: 'child');

    group('call method', () {
      test('returns next result when the schema route is absent', () {
        // arrange
        final actualGuard = InitializeSchemaNodeGuard(
          route: schemaRoute,
          builder: (node) => node.copyWith(children: [childRoute.toNode()]),
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode();

        // act
        final actual =
            actualGuard.call(actualOrigin, actualTarget, GuardContext());

        // assert
        expect(actual, isA<GuardResultNext>());
      });

      test('returns next result when the schema already has children', () {
        // arrange
        var actualBuilderCalls = 0;
        final actualGuard = InitializeSchemaNodeGuard(
          route: schemaRoute,
          builder: (node) {
            actualBuilderCalls++;
            return node.copyWith(children: [childRoute.toNode()]);
          },
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [
            schemaRoute.toNode(children: [childRoute.toNode()]),
          ],
        );

        // act
        final actual =
            actualGuard.call(actualOrigin, actualTarget, GuardContext());

        // assert
        expect(actual, isA<GuardResultNext>());
        expect(actualBuilderCalls, equals(0));
      });

      test('redirects with an initialised node when the schema has no children',
          () {
        // arrange
        final actualGuard = InitializeSchemaNodeGuard(
          route: schemaRoute,
          builder: (node) => node.copyWith(children: [childRoute.toNode()]),
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [schemaRoute.toNode()],
        );

        // act
        final actual =
            actualGuard.call(actualOrigin, actualTarget, GuardContext());

        // assert
        expect(actual, isA<GuardResultRedirect>());
        final actualSchemaNode = (actual as GuardResultRedirect)
            .target
            .toMutable()
            .findByRoute(schemaRoute);
        expect(
          actualSchemaNode?.children.map((c) => c.route),
          orderedEquals(<YxRoute>[childRoute]),
        );
      });

      test('cancels when the builder produces a node without children', () {
        // arrange
        final actualGuard = InitializeSchemaNodeGuard(
          route: schemaRoute,
          builder: (node) => node,
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [schemaRoute.toNode()],
        );

        // act
        final actual =
            actualGuard.call(actualOrigin, actualTarget, GuardContext());

        // assert
        expect(actual, isA<GuardResultCancel>());
      });

      test('applies arguments and extra from the builder result', () {
        // arrange
        final actualGuard = InitializeSchemaNodeGuard(
          route: schemaRoute,
          builder: (node) => node.copyWith(
            arguments: const {'a': '1'},
            extra: const {'e': 'ext'},
            children: [childRoute.toNode()],
          ),
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [schemaRoute.toNode()],
        );

        // act
        final actual =
            actualGuard.call(actualOrigin, actualTarget, GuardContext());

        // assert
        expect(actual, isA<GuardResultRedirect>());
        final actualSchemaNode = (actual as GuardResultRedirect)
            .target
            .toMutable()
            .findByRoute(schemaRoute);
        expect(actualSchemaNode?.arguments, equals(const {'a': '1'}));
        expect(actualSchemaNode?.extra, equals(const {'e': 'ext'}));
      });
    });
  });
}
