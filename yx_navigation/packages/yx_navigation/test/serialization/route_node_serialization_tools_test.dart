import 'package:collection/collection.dart';
import 'package:test/test.dart';
// internal type, not exported
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/serialization/route_node_serialization_tools.dart';

void main() {
  final node = RouteNode.fromRoute(
    route: const YxRoute(id: 'example_route'),
    arguments: const {
      'arg1': 'value1',
      'arg2': 'value2',
    },
    children: [
      RouteNode.fromRoute(
        route: const YxRoute(id: 'child_route'),
        arguments: const {
          'arg1': 'value1',
          'arg2': 'value2',
        },
      ),
    ],
  );
  group('RouteNodeSerializationTools', () {
    group('toJson', () {
      test('encoded json is equal to expected', () {
        const json = {
          RouteNodeSerializationTools.routeKey: {
            'id': 'example_route',
          },
          RouteNodeSerializationTools.argumentsKey: {
            'arg1': 'value1',
            'arg2': 'value2',
          },
          RouteNodeSerializationTools.childrenKey: [
            {
              RouteNodeSerializationTools.routeKey: {
                'id': 'child_route',
              },
              RouteNodeSerializationTools.argumentsKey: {
                'arg1': 'value1',
                'arg2': 'value2'
              },
            }
          ]
        };

        final encodedNode = RouteNodeSerializationTools.toJson(node);

        expect(
          const DeepCollectionEquality().equals(json, encodedNode),
          isTrue,
        );
      });
    });
    group('fromJson', () {
      test('decoded json is equal to expected', () {
        const json = {
          RouteNodeSerializationTools.routeKey: {
            'id': 'example_route',
          },
          RouteNodeSerializationTools.argumentsKey: {
            'arg1': 'value1',
            'arg2': 'value2',
          },
          RouteNodeSerializationTools.childrenKey: [
            {
              RouteNodeSerializationTools.routeKey: {
                'id': 'child_route',
              },
              RouteNodeSerializationTools.argumentsKey: {
                'arg1': 'value1',
                'arg2': 'value2'
              },
            }
          ]
        };

        final decodedNode = RouteNodeSerializationTools.fromJson(json);

        expect(
          decodedNode == node,
          isTrue,
        );
      });
    });
  });
}
