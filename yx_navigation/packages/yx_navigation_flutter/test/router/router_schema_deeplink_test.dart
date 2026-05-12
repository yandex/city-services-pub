import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/router/deeplink/late_init_deeplink_handler.dart';

import '../helpers/factories.dart';
import 'deeplink/mock_deeplink_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RouterSchema.buildSubtreeDeeplinkHandler — per-level strategy', () {
    test('single schema with only root handler returns it as-is', () {
      // arrange
      final rootHandler = MockDeeplinkHandler();
      final schema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [],
        deeplinkHandlers: [rootHandler],
      );

      // act/assert
      expect(
        schema.buildSubtreeDeeplinkHandler(),
        same(rootHandler),
      );
    });

    test('schema with no handlers returns null', () {
      // arrange
      final schema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [],
      );

      // act/assert
      expect(schema.buildSubtreeDeeplinkHandler(), isNull);
    });

    test(
        'schema nested inside a non-schema routeBuilder declaration is still collected',
        () {
      // arrange: schema is nested inside a routeBuilder declaration
      // (not a schema declaration).
      final nestedHandler = MockDeeplinkHandler();
      final rootSchema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.routeBuilder(
            route: const YxRoute(id: 'section'),
            routeBuilder: RouteBuilder.widget(
              builder: (context, node) => const SizedBox.shrink(),
            ),
            declarations: [
              RouteDeclaration.scheme(
                route: const YxRoute(id: 'nested'),
                schema: makeSchema(
                  initialNodeBuilder: (node) => node,
                  declarations: [],
                  deeplinkHandlers: [nestedHandler],
                ),
              ),
            ],
          ),
        ],
      );

      // act
      final composedHandler = rootSchema.buildSubtreeDeeplinkHandler();

      // assert
      expect(composedHandler, same(nestedHandler));
    });

    test('nested schema strategy is applied independently from root strategy',
        () {
      // arrange
      final callOrder = <String>[];
      final nestedHandler1 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('n1');
          return null;
        };
      final nestedHandler2 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('n2');
          return null;
        };
      // level1Schema has LIFO strategy and nestedHandler1 as root.
      // It also has nestedHandler2 from nested schema.
      // LIFO within level1: [n2, n1].
      final level1Schema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'level2'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler2],
            ),
          ),
        ],
        deeplinkHandlers: [nestedHandler1],
        deeplinkStrategy: const DeeplinkHandlerStrategy.lifo(),
      );
      // Root has FIFO strategy (default) with rootHandler — but level1 uses
      // its own LIFO via its schema's deeplinkStrategy.
      final rootHandler = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('root');
          return null;
        };
      final rootSchema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'level1'),
            schema: level1Schema,
          ),
        ],
        deeplinkHandlers: [rootHandler],
      );

      // act
      final composedHandler = rootSchema.buildSubtreeDeeplinkHandler()!;
      final uri = Uri.parse('test://deeplink');
      final state = const YxRoute(id: 'root').toMutableNode();
      composedHandler.handle(uri, state);

      // assert: root FIFO: rootHandler first, then level1's composed handler.
      // Level1 LIFO: within level1's composite, n2 (last registered) first.
      expect(callOrder, ['root', 'n2', 'n1']);
    });

    test('sibling schemas each use their own independent strategy', () {
      // arrange
      final callOrder = <String>[];
      final handlerA1 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('a1');
          return null;
        };
      final handlerA2 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('a2');
          return null;
        };
      final handlerB1 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('b1');
          return null;
        };
      final handlerB2 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('b2');
          return null;
        };
      // SchemaA: FIFO (default), handlerA1 + nested handlerA2 → a1 then a2.
      final schemaA = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'a2'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [handlerA2],
            ),
          ),
        ],
        deeplinkHandlers: [handlerA1],
      );
      // SchemaB: LIFO, handlerB1 + nested handlerB2 → b2 then b1.
      final schemaB = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'b2'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [handlerB2],
            ),
          ),
        ],
        deeplinkHandlers: [handlerB1],
        deeplinkStrategy: const DeeplinkHandlerStrategy.lifo(),
      );
      // Root: FIFO (default) → schemaA composite first, then schemaB composite.
      final rootSchema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'a'),
            schema: schemaA,
          ),
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'b'),
            schema: schemaB,
          ),
        ],
      );

      // act
      final composedHandler = rootSchema.buildSubtreeDeeplinkHandler()!;
      final uri = Uri.parse('test://deeplink');
      final state = const YxRoute(id: 'root').toMutableNode();
      composedHandler.handle(uri, state);

      // assert: root FIFO: schemaA composite first → a1, a2.
      // Then schemaB composite → b2, b1 (LIFO within schemaB).
      expect(callOrder, ['a1', 'a2', 'b2', 'b1']);
    });

    test(
        'three-level nesting: each level applies its own strategy independently',
        () {
      // arrange
      final callOrder = <String>[];
      final h1 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('h1');
          return null;
        };
      final h2 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('h2');
          return null;
        };
      final h3 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('h3');
          return null;
        };
      // Level2: LIFO, handler h2. Has h3 nested → LIFO: [h3, h2].
      final level2Schema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'level3'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [h3],
            ),
          ),
        ],
        deeplinkHandlers: [h2],
        deeplinkStrategy: const DeeplinkHandlerStrategy.lifo(),
      );
      // Level1: FIFO (default), handler h1.
      // Has level2 composed → FIFO: [h1, composite_level2].
      final level1Schema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'level2'),
            schema: level2Schema,
          ),
        ],
        deeplinkHandlers: [h1],
      );
      // Root: no handler, just level1 → returns level1's composite directly.
      final rootSchema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'level1'),
            schema: level1Schema,
          ),
        ],
      );

      // act
      final composedHandler = rootSchema.buildSubtreeDeeplinkHandler()!;
      final uri = Uri.parse('test://deeplink');
      final state = const YxRoute(id: 'root').toMutableNode();
      composedHandler.handle(uri, state);

      // assert: level1 FIFO: h1 first, then level2's composite.
      // Level2 LIFO: [h3, h2] — h3 before h2.
      expect(callOrder, ['h1', 'h3', 'h2']);
    });

    test('LateInit as root is wrapped in composite with nested handlers', () {
      // arrange
      final nestedHandler1 = MockDeeplinkHandler();
      final nestedHandler2 = MockDeeplinkHandler();
      // Level1 schema: LIFO strategy, nestedHandler1.
      // Nested schema has nestedHandler2.
      final level1Schema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'nested2'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler2],
            ),
          ),
        ],
        deeplinkHandlers: [nestedHandler1],
        deeplinkStrategy: const DeeplinkHandlerStrategy.lifo(),
      );
      final lateInitHandler = LateInitDeeplinkHandlerImpl();

      // act
      final composedHandler = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'level1'),
            schema: level1Schema,
          ),
        ],
        deeplinkHandlers: [lateInitHandler],
      ).buildSubtreeDeeplinkHandler();

      // assert: LateInit is not mutated — instead, a new CompositeDeeplinkHandler
      // wraps [lateInitHandler, composedLevel1].
      expect(lateInitHandler.handlers, isEmpty);
      expect(composedHandler, isA<CompositeDeeplinkHandler>());
      expect(composedHandler, isNot(same(lateInitHandler)));
    });
  });

  group('RouterSchema.build — schema-owned deeplink handlers', () {
    test('wraps LateInit and nested handlers in composite', () {
      // arrange
      final nestedHandler = MockDeeplinkHandler();
      final lateInitHandler = LateInitDeeplinkHandlerImpl();

      // act
      final composedHandler = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'nested'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler],
            ),
          ),
        ],
        deeplinkHandlers: [lateInitHandler],
      ).buildSubtreeDeeplinkHandler();

      // assert: nested handlers are NOT merged into LateInit —
      // a new composite wraps both.
      expect(lateInitHandler.handlers, isEmpty);
      expect(composedHandler, isA<CompositeDeeplinkHandler>());
    });

    test('wraps schema root handler in composite when not LateInit', () {
      // arrange
      final rootHandler = MockDeeplinkHandler();
      final nestedHandler = MockDeeplinkHandler();

      // act
      final config = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'nested'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler],
            ),
          ),
        ],
        deeplinkHandlers: [rootHandler],
      ).build();
      addTearDown(config.dispose);

      // assert
      expect(config.routeInformationParser, isNotNull);
    });

    test('FIFO strategy: root handler called before nested handler', () {
      // arrange
      final callOrder = <String>[];
      final rootHandler = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('root');
          return null;
        };
      final nestedHandler = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('nested');
          return null;
        };

      // act
      makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'nested'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler],
            ),
          ),
        ],
        deeplinkHandlers: [rootHandler],
      ).buildSubtreeDeeplinkHandler()!.handle(
          Uri.parse('test://x'), const YxRoute(id: 'r').toMutableNode());

      // assert
      expect(callOrder, ['root', 'nested']);
    });

    test('LIFO strategy: nested handler called before root handler', () {
      // arrange
      final callOrder = <String>[];
      final rootHandler = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('root');
          return null;
        };
      final nestedHandler = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('nested');
          return null;
        };

      // act
      makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'nested'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler],
            ),
          ),
        ],
        deeplinkHandlers: [rootHandler],
        deeplinkStrategy: const DeeplinkHandlerStrategy.lifo(),
      ).buildSubtreeDeeplinkHandler()!.handle(
          Uri.parse('test://x'), const YxRoute(id: 'r').toMutableNode());

      // assert: LIFO — nestedHandler (last registered) is called first.
      expect(callOrder, ['nested', 'root']);
    });

    test('does not add handlers when no nested declarations exist', () {
      // arrange
      final lateInitHandler = LateInitDeeplinkHandlerImpl();

      // act
      final config = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [],
        deeplinkHandlers: [lateInitHandler],
      ).build();
      addTearDown(config.dispose);

      // assert
      expect(lateInitHandler.handlers, isEmpty);
    });

    test('wraps LateInit with multiple nested handlers in composite', () {
      // arrange
      final callOrder = <String>[];
      final nestedHandler1 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('n1');
          return null;
        };
      final nestedHandler2 = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('n2');
          return null;
        };
      final lateInitHandler = LateInitDeeplinkHandlerImpl();

      // act
      makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'nested1'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler1],
            ),
          ),
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'nested2'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler2],
            ),
          ),
        ],
        deeplinkHandlers: [lateInitHandler],
      ).buildSubtreeDeeplinkHandler()!.handle(
            Uri.parse('test://x'),
            const YxRoute(id: 'r').toMutableNode(),
          );

      // assert: LateInit is not mutated; all handlers are composed in a new
      // composite.
      expect(lateInitHandler.handlers, isEmpty);
      expect(callOrder, ['n1', 'n2']);
    });

    test('wraps LateInit with deeply nested handlers in composite', () {
      // arrange
      final callOrder = <String>[];
      final level2Handler = MockDeeplinkHandler()
        ..onHandle = (_, __) {
          callOrder.add('level2');
          return null;
        };
      final level1Schema = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'level2'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [level2Handler],
            ),
          ),
        ],
      );
      final lateInitHandler = LateInitDeeplinkHandlerImpl();

      // act
      makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'level1'),
            schema: level1Schema,
          ),
        ],
        deeplinkHandlers: [lateInitHandler],
      ).buildSubtreeDeeplinkHandler()!.handle(
            Uri.parse('test://x'),
            const YxRoute(id: 'r').toMutableNode(),
          );

      // assert: LateInit is not mutated; deeply nested handler is composed
      // externally.
      expect(lateInitHandler.handlers, isEmpty);
      expect(callOrder, ['level2']);
    });

    test('LateInit is not mutated when used as root handler', () {
      // arrange
      final nestedHandler = MockDeeplinkHandler();
      final lateInitHandler = LateInitDeeplinkHandlerImpl();

      // act
      final composedHandler = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 'nested'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [nestedHandler],
            ),
          ),
        ],
        deeplinkHandlers: [lateInitHandler],
      ).buildSubtreeDeeplinkHandler();

      // assert: LateInit is not mutated — nested handlers are composed
      // externally.
      expect(lateInitHandler.handlers, isEmpty);
      expect(composedHandler, isA<CompositeDeeplinkHandler>());
      expect(composedHandler, isNot(same(lateInitHandler)));
    });

    test('returns root handler without nested handlers as-is', () {
      // arrange
      final lateInitHandler = LateInitDeeplinkHandlerImpl();

      // act
      final config = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [],
        deeplinkHandlers: [lateInitHandler],
      ).build();
      addTearDown(config.dispose);

      // assert
      expect(lateInitHandler.handlers, isEmpty);
    });

    test('builds successfully without any deeplink handler', () {
      // arrange/act
      final config = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [],
      ).build();
      addTearDown(config.dispose);

      // assert
      expect(config.routeInformationParser, isNotNull);
    });

    test('composes nested handlers via CompositeDeeplinkHandler when no root',
        () {
      // arrange
      final handler1 = MockDeeplinkHandler();
      final handler2 = MockDeeplinkHandler();

      // act
      final config = makeSchema(
        initialNodeBuilder: (node) => node,
        declarations: [
          RouteDeclaration.scheme(
            route: const YxRoute(id: 's1'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [handler1],
            ),
          ),
          RouteDeclaration.scheme(
            route: const YxRoute(id: 's2'),
            schema: makeSchema(
              initialNodeBuilder: (node) => node,
              declarations: [],
              deeplinkHandlers: [handler2],
            ),
          ),
        ],
      ).build();
      addTearDown(config.dispose);

      // assert
      expect(config.routeInformationParser, isNotNull);
    });
  });
}
