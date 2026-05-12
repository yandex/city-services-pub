import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('RouteWidgetBuilder', () {
    testWidgets('invokes the provided builder with route node', (tester) async {
      // arrange
      RouteNode? observedNode;
      final actualBuilder = RouteBuilder<Object?>.widget(
        builder: (context, node) {
          observedNode = node;
          return const SizedBox.shrink();
        },
      );
      final expectedNode = makeNode();

      // act
      await tester.pumpWidget(
        Builder(
          builder: (context) => actualBuilder.builder(context, expectedNode),
        ),
      );

      // assert
      expect(observedNode, same(expectedNode));
    });
  });
}
