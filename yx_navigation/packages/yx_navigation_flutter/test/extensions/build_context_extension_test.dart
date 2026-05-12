import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/route_node_builder.dart';
import 'package:yx_navigation_flutter/src/extensions/build_context_extension.dart';
import 'package:yx_navigation_flutter/src/router/yx_navigation.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

// internal test helper, not exported
class _StubRouteNodeBuilder implements RouteNodeBuilder {
  @override
  Iterable<RoutePageEntry> buildPages(
    BuildContext context,
    Iterable<RouteNode> routeNodes,
  ) =>
      const [];

  @override
  Widget buildWidget(BuildContext context, RouteNode routeNode) =>
      const SizedBox.shrink();

  @override
  Widget emptyWidgetBuilder(BuildContext context, RouteNode routeNode) =>
      const SizedBox.shrink();
}

void main() {
  setUpAll(registerFallbacks);

  group('BuildContextExtension', () {
    testWidgets(
        'getters return the installed YxNavigation values when provider is '
        'present in the tree', (tester) async {
      // arrange: full YxNavigation.provider tree.
      final stateManager = RouteNodeStateManager(routeNode: makeNode());
      addTearDown(stateManager.close);
      final parentController = NavigationController.node(
        stateManager: stateManager,
        nodeResolver: RouteNodeResolver.id(route: stateManager.state.route),
      );
      final navigationController = NavigationController.node(
        stateManager: stateManager,
        nodeResolver: RouteNodeResolver.id(route: stateManager.state.route),
      );
      final routeNodeBuilder = _StubRouteNodeBuilder();
      BuildContext? capturedContext;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: YxNavigation.provider(
            routeNode: stateManager.state,
            stateManager: stateManager,
            navigationController: navigationController,
            parentNavigationController: parentController,
            routeNodeBuilder: routeNodeBuilder,
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // act/assert: each getter returns the installed instance.
      expect(capturedContext!.stateManager, same(stateManager));
      expect(capturedContext!.navigationController, same(navigationController));
      expect(
        capturedContext!.routeNavigator,
        same(navigationController),
        reason: 'routeNavigator == current navigation controller',
      );
      expect(
        capturedContext!.rootRouteNavigator,
        same(stateManager),
        reason: 'rootRouteNavigator == stateManager when isRoot',
      );
      expect(capturedContext!.routeMutator, same(navigationController));
      expect(capturedContext!.routeNodeBuilder, same(routeNodeBuilder));
      expect(capturedContext!.parentRouteNavigator, same(parentController));
    });

    testWidgets('extension methods throw when YxNavigation is absent',
        (tester) async {
      // arrange
      BuildContext? capturedContext;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );

      // act/assert
      expect(() => capturedContext!.stateManager, throwsA(isA<Error>()));
      expect(
        () => capturedContext!.routeNavigator,
        throwsA(isA<Error>()),
      );
      expect(
        () => capturedContext!.routeMutator,
        throwsA(isA<Error>()),
      );
      expect(
        () => capturedContext!.rootRouteNavigator,
        throwsA(isA<Error>()),
      );
      expect(
        () => capturedContext!.routeNodeBuilder,
        throwsA(isA<Error>()),
      );
      expect(capturedContext!.navigationController, isNull);
      expect(
        () => capturedContext!.parentRouteNavigator,
        throwsA(isA<Error>()),
      );
    });
  });
}
