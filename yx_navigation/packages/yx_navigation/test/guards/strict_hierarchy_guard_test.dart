import 'package:test/test.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';
import 'package:yx_navigation/src/guard/default/strict_hierarchy_guard.dart';
import 'package:yx_navigation/src/guard/guard_context.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';

import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('StrictHierarchyGuard', () {
    const rootRoute = YxRoute(id: 'root');
    const parentRoute = YxRoute(id: 'parent');
    const childA = YxRoute(id: 'childA');
    const childB = YxRoute(id: 'childB');
    const undeclared = YxRoute(id: 'undeclared');

    group('call method', () {
      test('returns next result when only declared children are present', () {
        // arrange
        const actualGuard = StrictHierarchyGuard(
          route: parentRoute,
          declaredRoutes: [childA, childB],
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [
            parentRoute.toNode(
              children: [childA.toNode(), childB.toNode()],
            ),
          ],
        );

        // act
        final actual =
            actualGuard.call(actualOrigin, actualTarget, GuardContext());

        // assert
        expect(actual, isA<GuardResultNext>());
      });

      test('returns next result when parent has no children', () {
        // arrange
        const actualGuard = StrictHierarchyGuard(
          route: parentRoute,
          declaredRoutes: [childA],
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [parentRoute.toNode()],
        );

        // act
        final actual =
            actualGuard.call(actualOrigin, actualTarget, GuardContext());

        // assert
        expect(actual, isA<GuardResultNext>());
      });

      test('returns next result when the guarded route is absent from the tree',
          () {
        // arrange
        const actualGuard = StrictHierarchyGuard(
          route: parentRoute,
          declaredRoutes: [childA],
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [undeclared.toNode()],
        );

        // act
        final actual =
            actualGuard.call(actualOrigin, actualTarget, GuardContext());

        // assert
        expect(actual, isA<GuardResultNext>());
      });

      test('throws StateError when parent contains an undeclared child', () {
        // arrange
        const actualGuard = StrictHierarchyGuard(
          route: parentRoute,
          declaredRoutes: [childA, childB],
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [
            parentRoute.toNode(
              children: [childA.toNode(), undeclared.toNode()],
            ),
          ],
        );

        // act & assert
        expect(
          () => actualGuard.call(actualOrigin, actualTarget, GuardContext()),
          throwsStateError,
        );
      });

      test(
          'throws StateError when declared list is empty and parent has children',
          () {
        // arrange
        const actualGuard = StrictHierarchyGuard(
          route: parentRoute,
          declaredRoutes: <YxRoute>[],
        );
        final actualOrigin = rootRoute.toNode();
        final actualTarget = rootRoute.toNode(
          children: [
            parentRoute.toNode(children: [childA.toNode()]),
          ],
        );

        // act & assert
        expect(
          () => actualGuard.call(actualOrigin, actualTarget, GuardContext()),
          throwsStateError,
        );
      });
    });
  });
}
