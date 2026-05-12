import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/base/route_node_widget_builder.dart';
import 'package:yx_navigation_flutter/src/router/route_node_provider.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('RouteNodeWidgetBuilder', () {
    testWidgets(
        'toWidget wraps declaration-provided widget with RouteNodeProvider',
        (tester) async {
      // arrange
      const actualBuilder = RouteNodeWidgetBuilder();
      final expectedNode = makeNode(route: makeRoute(id: 'home'));
      final actualDeclaration = RouteDeclaration.routeBuilder(
        route: expectedNode.route,
        routeBuilder: RouteBuilder<Object?>.widget(
          builder: (context, node) => Text('route:${node.route.id}'),
        ),
      );

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => actualBuilder.toWidget(
              context,
              expectedNode,
              actualDeclaration,
            ),
          ),
        ),
      );

      // assert
      expect(find.text('route:home'), findsOneWidget);
      expect(find.byType(RouteNodeProvider), findsOneWidget);
    });
  });
}
