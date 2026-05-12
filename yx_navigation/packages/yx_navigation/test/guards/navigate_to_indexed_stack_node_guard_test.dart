import 'package:test/test.dart';
import 'package:yx_navigation/src/base/equality/route_node_equality.dart';
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/extensions/route_node_extensions.dart';
import 'package:yx_navigation/src/guard/default/navigate_to_indexed_stack_node_guard.dart';
import 'package:yx_navigation/src/guard/guard_context.dart';
import 'package:yx_navigation/src/guard/guard_result.dart';

class TestRoutes {
  static const YxRoute root = YxRoute(id: 'root');
  static const YxRoute indexedStack = YxRoute(id: 'indexed_stack');
  static const YxRoute tab1 = YxRoute(id: 'tab1');
  static const YxRoute tab2 = YxRoute(id: 'tab2');
  static const YxRoute tab3 = YxRoute(id: 'tab3');
  static const YxRoute other = YxRoute(id: 'other');
}

void main() {
  late GuardContext context;

  setUp(() {
    context = GuardContext();
  });

  group('NavigateToIndexedStackNodeGuard', () {
    test('returns next result when indexed stack node is not in tree', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.other.toNode();

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultNext>());
    });

    test('initializes children when indexed stack node has none', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [TestRoutes.indexedStack.toNode()],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);
      expect(
        indexedStackNode?.children.map((e) => e.route),
        orderedEquals([TestRoutes.tab1, TestRoutes.tab2]),
      );
    });

    test('returns next result when all declared children are present', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [
          TestRoutes.indexedStack.toNode(
            children: [
              TestRoutes.tab1.toNode(),
              TestRoutes.tab2.toNode(),
            ],
          ),
        ],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultNext>());
    });

    test('restores children when some declared routes are missing', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [
          TestRoutes.indexedStack.toNode(
            children: [TestRoutes.tab1.toNode()],
          ),
        ],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);
      expect(
        indexedStackNode?.children.map((e) => e.route),
        orderedEquals([TestRoutes.tab1, TestRoutes.tab2]),
      );
    });

    test('replaces children when wrong routes are present', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [
          TestRoutes.indexedStack.toNode(
            children: [
              TestRoutes.other.toNode(),
              TestRoutes.tab3.toNode(),
            ],
          ),
        ],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);
      expect(
        indexedStackNode?.children.map((e) => e.route),
        orderedEquals([TestRoutes.tab1, TestRoutes.tab2]),
      );
    });

    test('returns cancel result when declaredRoutes is empty', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [TestRoutes.indexedStack.toNode()],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultCancel>());
    });

    test('initializes with single declared route when only one is declared',
        () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [TestRoutes.indexedStack.toNode()],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);
      expect(indexedStackNode, isNotNull);
      expect(indexedStackNode!.children, hasLength(1));
      expect(indexedStackNode.children.first.route, equals(TestRoutes.tab1));
    });

    test('handles nested indexed stack node', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [
          TestRoutes.other.toNode(
            children: [TestRoutes.indexedStack.toNode()],
          ),
        ],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);
      expect(
        indexedStackNode?.children.map((e) => e.route),
        orderedEquals([TestRoutes.tab1, TestRoutes.tab2]),
      );
    });

    test('preserves arguments and extra when restoring missing children', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3],
      );
      final tab1Arguments = {'arg1': 'val1'};
      final tab1Extra = {'extra1': 'extraVal1'};
      final tab3Arguments = {'arg3': 'val3'};
      final tab3Extra = {'extra3': 'extraVal3'};

      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [
          TestRoutes.indexedStack.toNode(
            children: [
              TestRoutes.tab1.toNode(
                arguments: tab1Arguments,
                extra: tab1Extra,
              ),
              TestRoutes.tab3.toNode(
                arguments: tab3Arguments,
                extra: tab3Extra,
              ),
            ],
          ),
        ],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);

      expect(
        indexedStackNode?.children.map((e) => e.route),
        containsAllInOrder([
          TestRoutes.tab1,
          TestRoutes.tab3,
          TestRoutes.tab2,
        ]),
      );

      final expectedTab1 = TestRoutes.tab1.toNode(
        arguments: tab1Arguments,
        extra: tab1Extra,
      );
      final actualTab1Node = indexedStackNode?.children
          .firstWhere((child) => child.route == TestRoutes.tab1);
      expect(
        const RouteNodeEquality.deep().equals(actualTab1Node!, expectedTab1),
        isTrue,
      );

      final expectedTab2Node = TestRoutes.tab2.toNode();
      final actualTab2Node = indexedStackNode?.children
          .firstWhere((child) => child.route == TestRoutes.tab2);
      expect(
        const RouteNodeEquality.deep()
            .equals(actualTab2Node!, expectedTab2Node),
        isTrue,
      );

      final expectedTab3Node = TestRoutes.tab3.toNode(
        arguments: tab3Arguments,
        extra: tab3Extra,
      );
      final actualTab3Node = indexedStackNode?.children
          .firstWhere((child) => child.route == TestRoutes.tab3);
      expect(
        const RouteNodeEquality.deep()
            .equals(actualTab3Node!, expectedTab3Node),
        isTrue,
      );
    });

    test('adds missing routes while preserving existing ones with data', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [
          TestRoutes.indexedStack.toNode(
            children: [
              TestRoutes.tab3
                  .toNode(arguments: {'id': '3'}, extra: {'extra': 'data3'}),
              TestRoutes.tab1
                  .toNode(arguments: {'id': '1'}, extra: {'extra': 'data1'}),
            ],
          ),
        ],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);
      expect(
        indexedStackNode?.children.map((e) => e.route),
        containsAllInOrder([
          TestRoutes.tab3,
          TestRoutes.tab1,
          TestRoutes.tab2,
        ]),
      );

      final expectedTab1Node = TestRoutes.tab1.toNode(
        arguments: {'id': '1'},
        extra: {'extra': 'data1'},
      );
      final actualTab1Node = indexedStackNode?.children
          .firstWhere((child) => child.route == TestRoutes.tab1);
      expect(
        const RouteNodeEquality.deep()
            .equals(actualTab1Node!, expectedTab1Node),
        isTrue,
      );

      final expectedTab2Node = TestRoutes.tab2.toNode();
      final actualTab2Node = indexedStackNode?.children
          .firstWhere((child) => child.route == TestRoutes.tab2);
      expect(
        const RouteNodeEquality.deep()
            .equals(actualTab2Node!, expectedTab2Node),
        isTrue,
      );

      final expectedTab3Node = TestRoutes.tab3.toNode(
        arguments: {'id': '3'},
        extra: {'extra': 'data3'},
      );
      final actualTab3Node = indexedStackNode?.children
          .firstWhere((child) => child.route == TestRoutes.tab3);
      expect(
        const RouteNodeEquality.deep()
            .equals(actualTab3Node!, expectedTab3Node),
        isTrue,
      );
    });

    test('preserves children navigation state when restoring missing routes',
        () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2, TestRoutes.tab3],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [
          TestRoutes.indexedStack.toNode(
            children: [
              TestRoutes.tab1.toNode(
                arguments: {'id': '1'},
                children: [
                  TestRoutes.other.toNode(arguments: {'nested': 'data'}),
                ],
              ),
            ],
          ),
        ],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);
      final actualTab1Node = indexedStackNode?.children
          .firstWhere((child) => child.route == TestRoutes.tab1);

      final expectedTab1Node = TestRoutes.tab1.toNode(
        arguments: {'id': '1'},
        children: [
          TestRoutes.other.toNode(arguments: {'nested': 'data'}),
        ],
      );

      expect(
        const RouteNodeEquality.deep()
            .equals(actualTab1Node!, expectedTab1Node),
        isTrue,
      );
    });

    test('preserves children state when removing invalid routes', () {
      // arrange
      const guard = NavigateToIndexedStackNodeGuard(
        route: TestRoutes.indexedStack,
        declaredRoutes: [TestRoutes.tab1, TestRoutes.tab2],
      );
      final origin = TestRoutes.root.toNode();
      final target = TestRoutes.root.toNode(
        children: [
          TestRoutes.indexedStack.toNode(
            children: [
              TestRoutes.tab1.toNode(
                arguments: {'id': '1'},
                children: [
                  TestRoutes.other.toNode(arguments: {'child': 'data'}),
                ],
              ),
              TestRoutes.tab3.toNode(arguments: {'id': '3'}),
            ],
          ),
        ],
      );

      // act
      final actual = guard.call(origin, target, context);

      // assert
      expect(actual, isA<GuardResultRedirect>());
      final redirectResult = actual as GuardResultRedirect;
      final indexedStackNode = redirectResult.target
          .toMutable()
          .findByRoute(TestRoutes.indexedStack);
      expect(
        indexedStackNode?.children.map((e) => e.route),
        orderedEquals([TestRoutes.tab1, TestRoutes.tab2]),
      );

      final actualTab1Node = indexedStackNode?.children
          .firstWhere((child) => child.route == TestRoutes.tab1);
      final expectedTab1Node = TestRoutes.tab1.toNode(
        arguments: {'id': '1'},
        children: [
          TestRoutes.other.toNode(arguments: {'child': 'data'}),
        ],
      );
      expect(
        const RouteNodeEquality.deep()
            .equals(actualTab1Node!, expectedTab1Node),
        isTrue,
      );
    });
  });
}
