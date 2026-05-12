import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';

import '../helpers/factories.dart';

/// Route identifiers for the first two tests: [tab_host] (indexed stack),
/// [tabA] / [tabB], and nested outlet trees.
abstract final class _Routes {
  static const tabHost = YxRoute(id: 'tab_host');
  static const tabA = YxRoute(id: 'tab_a');
  static const tabB = YxRoute(id: 'tab_b');
  static const tabANodeA = YxRoute(id: 'tab_a_node_a');
  static const tabANodeB = YxRoute(id: 'tab_a_node_b');
  static const tabANodeALeafA = YxRoute(id: 'tab_a_node_a_leaf_a');
  static const tabANodeALeafB = YxRoute(id: 'tab_a_node_a_leaf_b');
  static const tabANodeBLeafA = YxRoute(id: 'tab_a_node_b_leaf_a');
  static const tabANodeBLeafB = YxRoute(id: 'tab_a_node_b_leaf_b');
  static const tabBNodeA = YxRoute(id: 'tab_b_node_a');
  static const tabBNodeB = YxRoute(id: 'tab_b_node_b');
  static const tabBNodeALeafA = YxRoute(id: 'tab_b_node_a_leaf_a');
  static const tabBNodeALeafB = YxRoute(id: 'tab_b_node_a_leaf_b');
  static const tabBNodeBLeafA = YxRoute(id: 'tab_b_node_b_leaf_a');
  static const tabBNodeBLeafB = YxRoute(id: 'tab_b_node_b_leaf_b');
}

/// Route identifiers for the third test
/// (`system back pops leaf inside nested outlet when page hosts inner indexed stack`):
/// [nestedList] → [nestedIndexedStack], with [innerTabA] / [innerTabB] and leaves inside.
abstract final class _Routes2 {
  static const nestedList = YxRoute(id: 'tab_b_nested_list');
  static const nestedIndexedStack = YxRoute(id: 'tab_b_nested_indexed_stack');
  static const innerTabA = YxRoute(id: 'tab_b_inner_tab_a');
  static const innerTabALeafA = YxRoute(id: 'tab_b_inner_tab_a_leaf_a');
  static const innerTabALeafB = YxRoute(id: 'tab_b_inner_tab_a_leaf_b');
  static const innerTabB = YxRoute(id: 'tab_b_inner_tab_b');
  static const innerBLeafA = YxRoute(id: 'tab_b_inner_b_leaf_a');
  static const innerBLeafB = YxRoute(id: 'tab_b_inner_b_leaf_b');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Scenario under test:
  ///
  /// Before:
  /// ```text
  /// tab_host
  ///   tab_a
  ///     outletNode
  ///       tab_a_node_a
  ///         outletNode
  ///           tab_a_node_a_leaf_a
  ///           tab_a_node_a_leaf_b
  ///       tab_a_node_b
  ///         outletNode
  ///           tab_a_node_b_leaf_a
  ///           tab_a_node_b_leaf_b
  ///   tab_b   [active tab]
  ///     outletNode
  ///       tab_b_node_a
  ///         outletNode
  ///           tab_b_node_a_leaf_a
  ///           tab_b_node_a_leaf_b
  ///       tab_b_node_b
  ///         outletNode
  ///           tab_b_node_b_leaf_a
  ///           tab_b_node_b_leaf_b
  /// ```
  ///
  /// *system back pressed*
  ///
  /// Expected:
  /// ```text
  /// tab_host
  ///   tab_a
  ///     outletNode
  ///       tab_a_node_a
  ///         outletNode
  ///           tab_a_node_a_leaf_a
  ///           tab_a_node_a_leaf_b
  ///       tab_a_node_b
  ///         outletNode
  ///           tab_a_node_b_leaf_a
  ///           tab_a_node_b_leaf_b
  ///   tab_b   [active tab]
  ///     outletNode
  ///       tab_b_node_a
  ///         outletNode
  ///           tab_b_node_a_leaf_a
  ///           tab_b_node_a_leaf_b
  ///       tab_b_node_b
  ///         outletNode
  ///           tab_b_node_b_leaf_a
  /// ```
  testWidgets('system back removes only top leaf in active nested subtree',
      (tester) async {
    final config = makeSchema(
      initialNodeBuilder: (node) => node
        ..setChildren(
          [_Routes.tabHost.toMutableNode()],
        ),
      declarations: [
        RouteDeclaration.indexedStack(
          route: _Routes.tabHost,
          routeBuilder: RouteBuilder.indexed(
            indexedBuilder: (_, __, child, ___) => child,
          ),
          declarations: [
            RouteDeclaration.routeBuilder(
              route: _Routes.tabA,
              routeBuilder: const RouteBuilder.outlet(),
              declarations: [
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabANodeA,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeALeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeALeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeALeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeALeafB'),
                      ),
                    ),
                  ],
                ),
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabANodeB,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeBLeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeBLeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeBLeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeBLeafB'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            RouteDeclaration.routeBuilder(
              route: _Routes.tabB,
              routeBuilder: const RouteBuilder.outlet(),
              declarations: [
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabBNodeA,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabBNodeALeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabBNodeALeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabBNodeALeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabBNodeALeafB'),
                      ),
                    ),
                  ],
                ),
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabBNodeB,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabBNodeBLeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabBNodeBLeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabBNodeBLeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabBNodeBLeafB'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ).build();
    addTearDown(config.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: config));

    final stateManager = config.routerDelegate.stateManager;
    stateManager.mutate((root) {
      final rootRoute = root.findByRoute(_Routes.tabHost);
      if (rootRoute == null) {
        return root;
      }

      rootRoute.setChildren([
        _Routes.tabA.toNode(
          children: [
            _Routes.tabANodeA.toNode(
              children: [
                _Routes.tabANodeALeafA.toNode(),
                _Routes.tabANodeALeafB.toNode(),
              ],
            ),
            _Routes.tabANodeB.toNode(
              children: [
                _Routes.tabANodeBLeafA.toNode(),
                _Routes.tabANodeBLeafB.toNode(),
              ],
            ),
          ],
        ),
        _Routes.tabB.toNode(
          children: [
            _Routes.tabBNodeA.toNode(
              children: [
                _Routes.tabBNodeALeafA.toNode(),
                _Routes.tabBNodeALeafB.toNode(),
              ],
            ),
            _Routes.tabBNodeB.toNode(
              children: [
                _Routes.tabBNodeBLeafA.toNode(),
                _Routes.tabBNodeBLeafB.toNode(),
              ],
            ),
          ],
        ),
      ]);
      return root;
    });
    await tester.pumpAndSettle();

    expect(find.text('tabBNodeBLeafB'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final tabB = stateManager.state.findByRoute(_Routes.tabB);
    final tabBNodeA = stateManager.state.findByRoute(_Routes.tabBNodeA);
    final tabBNodeB = stateManager.state.findByRoute(_Routes.tabBNodeB);

    expect(
      tabB?.children.map((node) => node.route),
      orderedEquals([_Routes.tabBNodeA, _Routes.tabBNodeB]),
    );
    expect(
      tabBNodeA?.children.map((node) => node.route),
      orderedEquals([_Routes.tabBNodeALeafA, _Routes.tabBNodeALeafB]),
    );
    expect(
      tabBNodeB?.children.map((node) => node.route),
      orderedEquals([_Routes.tabBNodeBLeafA]),
    );
    expect(find.text('tabBNodeBLeafA'), findsOneWidget);
    expect(find.text('tabBNodeBLeafB'), findsNothing);
  });

  /// Scenario under test:
  ///
  /// Before:
  /// ```text
  /// tab_host
  ///   tab_a
  ///     outletNode
  ///       tab_a_node_a
  ///         outletNode
  ///           tab_a_node_a_leaf_a
  ///           tab_a_node_a_leaf_b
  ///       tab_a_node_b
  ///         outletNode
  ///           tab_a_node_b_leaf_a
  ///           tab_a_node_b_leaf_b
  ///   tab_b   [active tab]
  ///     outletNode
  ///       tab_b_node_a
  ///         outletNode
  ///           tab_b_node_a_leaf_a
  ///           tab_b_node_a_leaf_b
  ///       tab_b_node_b
  ///         outletNode
  ///           tab_b_node_b_leaf_a
  /// ```
  ///
  /// *system back pressed*
  ///
  /// Expected:
  /// ```text
  /// tab_host
  ///   tab_a
  ///     outletNode
  ///       tab_a_node_a
  ///         outletNode
  ///           tab_a_node_a_leaf_a
  ///           tab_a_node_a_leaf_b
  ///       tab_a_node_b
  ///         outletNode
  ///           tab_a_node_b_leaf_a
  ///           tab_a_node_b_leaf_b
  ///   tab_b   [active tab]
  ///     outletNode
  ///       tab_b_node_a
  ///         outletNode
  ///           tab_b_node_a_leaf_a
  ///           tab_b_node_a_leaf_b
  /// ```
  testWidgets(
      'system back removes subtree when active nested outlet has one leaf',
      (tester) async {
    final config = makeSchema(
      initialNodeBuilder: (node) => node..add(_Routes.tabHost.toMutableNode()),
      declarations: [
        RouteDeclaration.indexedStack(
          route: _Routes.tabHost,
          routeBuilder: RouteBuilder.indexed(
            indexedBuilder: (_, __, child, ___) => child,
          ),
          declarations: [
            RouteDeclaration.routeBuilder(
              route: _Routes.tabA,
              routeBuilder: const RouteBuilder.outlet(),
              declarations: [
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabANodeA,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeALeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeALeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeALeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeALeafB'),
                      ),
                    ),
                  ],
                ),
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabANodeB,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeBLeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeBLeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeBLeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeBLeafB'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            RouteDeclaration.routeBuilder(
              route: _Routes.tabB,
              routeBuilder: const RouteBuilder.outlet(),
              declarations: [
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabBNodeA,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabBNodeALeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabBNodeALeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabBNodeALeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabBNodeALeafB'),
                      ),
                    ),
                  ],
                ),
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabBNodeB,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabBNodeBLeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabBNodeBLeafA'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ).build();
    addTearDown(config.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: config));

    final stateManager = config.routerDelegate.stateManager;
    stateManager.mutate((root) {
      final rootRoute = root.findByRoute(_Routes.tabHost);
      if (rootRoute == null) {
        return root;
      }

      rootRoute.setChildren([
        _Routes.tabA.toNode(
          children: [
            _Routes.tabANodeA.toNode(
              children: [
                _Routes.tabANodeALeafA.toNode(),
                _Routes.tabANodeALeafB.toNode(),
              ],
            ),
            _Routes.tabANodeB.toNode(
              children: [
                _Routes.tabANodeBLeafA.toNode(),
                _Routes.tabANodeBLeafB.toNode(),
              ],
            ),
          ],
        ),
        _Routes.tabB.toNode(
          children: [
            _Routes.tabBNodeA.toNode(
              children: [
                _Routes.tabBNodeALeafA.toNode(),
                _Routes.tabBNodeALeafB.toNode(),
              ],
            ),
            _Routes.tabBNodeB.toNode(
              children: [
                _Routes.tabBNodeBLeafA.toNode(),
              ],
            ),
          ],
        ),
      ]);
      return root;
    });
    await tester.pumpAndSettle();

    expect(find.text('tabBNodeBLeafA'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final tabB = stateManager.state.findByRoute(_Routes.tabB);
    final tabBNodeA = stateManager.state.findByRoute(_Routes.tabBNodeA);

    expect(
      tabB?.children.map((node) => node.route),
      orderedEquals([_Routes.tabBNodeA]),
    );
    expect(
      tabBNodeA?.children.map((node) => node.route),
      orderedEquals([_Routes.tabBNodeALeafA, _Routes.tabBNodeALeafB]),
    );
    expect(stateManager.state.findByRoute(_Routes.tabBNodeB), isNull);
    expect(find.text('tabBNodeALeafB'), findsOneWidget);
    expect(find.text('tabBNodeBLeafA'), findsNothing);
  });

  /// [tab_a] has its own indexed stack (two slots with outlets inside); [tab_b]
  /// has nested outlet navigation: a list, then a screen with an inner indexed
  /// stack; the active inner tab has its own outlet with a leaf stack.
  ///
  /// Before:
  /// ```text
  /// tab_host
  ///   tab_a
  ///     indexedStack (tab bar)
  ///       tab_a_node_a
  ///         outletNode
  ///           tab_a_node_a_leaf_a
  ///           tab_a_node_a_leaf_b
  ///       tab_a_node_b   [active tab_a slot]
  ///         outletNode
  ///           tab_a_node_b_leaf_a
  ///           tab_a_node_b_leaf_b
  ///   tab_b   [active root tab]
  ///     outletNode
  ///       tab_b_nested_list
  ///       tab_b_nested_indexed_stack
  ///         indexedStack (inner tab bar)
  ///           tab_b_inner_tab_a
  ///             outletNode
  ///               tab_b_inner_tab_a_leaf_a
  ///               tab_b_inner_tab_a_leaf_b
  ///           tab_b_inner_tab_b   [active inner tab]
  ///             outletNode
  ///               tab_b_inner_b_leaf_a
  ///               tab_b_inner_b_leaf_b   [top of inner stack]
  /// ```
  ///
  /// *system back pressed*
  ///
  /// Expected:
  /// ```text
  /// tab_host
  ///   tab_a
  ///     indexedStack
  ///       tab_a_node_a
  ///         outletNode
  ///           tab_a_node_a_leaf_a
  ///           tab_a_node_a_leaf_b
  ///       tab_a_node_b   [active tab_a slot]
  ///         outletNode
  ///           tab_a_node_b_leaf_a
  ///           tab_a_node_b_leaf_b
  ///   tab_b   [active root tab]
  ///     outletNode
  ///       tab_b_nested_list
  ///       tab_b_nested_indexed_stack
  ///         indexedStack
  ///           tab_b_inner_tab_a
  ///             outletNode
  ///               tab_b_inner_tab_a_leaf_a
  ///               tab_b_inner_tab_a_leaf_b
  ///           tab_b_inner_tab_b   [active inner tab]
  ///             outletNode
  ///               tab_b_inner_b_leaf_a
  /// ```
  testWidgets(
      'system back pops leaf inside nested outlet when page hosts inner indexed stack',
      (tester) async {
    final config = makeSchema(
      initialNodeBuilder: (node) => node..add(_Routes.tabHost.toMutableNode()),
      declarations: [
        RouteDeclaration.indexedStack(
          route: _Routes.tabHost,
          routeBuilder: RouteBuilder.indexed(
            indexedBuilder: (_, __, child, ___) => child,
          ),
          declarations: [
            RouteDeclaration.indexedStack(
              route: _Routes.tabA,
              routeBuilder: RouteBuilder.indexed(
                indexedBuilder: (_, __, child, ___) => child,
              ),
              declarations: [
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabANodeA,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeALeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeALeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeALeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeALeafB'),
                      ),
                    ),
                  ],
                ),
                RouteDeclaration.routeBuilder(
                  route: _Routes.tabANodeB,
                  routeBuilder: const RouteBuilder.outlet(),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeBLeafA,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeBLeafA'),
                      ),
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes.tabANodeBLeafB,
                      routeBuilder: RouteBuilder.widget(
                        builder: (_, __) => const Text('tabANodeBLeafB'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            RouteDeclaration.routeBuilder(
              route: _Routes.tabB,
              routeBuilder: const RouteBuilder.outlet(),
              declarations: [
                RouteDeclaration.routeBuilder(
                  route: _Routes2.nestedList,
                  routeBuilder: RouteBuilder.widget(
                    builder: (_, __) => const Text('tabBNestedList'),
                  ),
                ),
                RouteDeclaration.indexedStack(
                  route: _Routes2.nestedIndexedStack,
                  routeBuilder: RouteBuilder.indexed(
                    indexedBuilder: (_, __, child, ___) => child,
                  ),
                  declarations: [
                    RouteDeclaration.routeBuilder(
                      route: _Routes2.innerTabA,
                      routeBuilder: const RouteBuilder.outlet(),
                      declarations: [
                        RouteDeclaration.routeBuilder(
                          route: _Routes2.innerTabALeafA,
                          routeBuilder: RouteBuilder.widget(
                            builder: (_, __) =>
                                const Text('tabBInnerTabALeafA'),
                          ),
                        ),
                        RouteDeclaration.routeBuilder(
                          route: _Routes2.innerTabALeafB,
                          routeBuilder: RouteBuilder.widget(
                            builder: (_, __) =>
                                const Text('tabBInnerTabALeafB'),
                          ),
                        ),
                      ],
                    ),
                    RouteDeclaration.routeBuilder(
                      route: _Routes2.innerTabB,
                      routeBuilder: const RouteBuilder.outlet(),
                      declarations: [
                        RouteDeclaration.routeBuilder(
                          route: _Routes2.innerBLeafA,
                          routeBuilder: RouteBuilder.widget(
                            builder: (_, __) => const Text('tabBInnerBLeafA'),
                          ),
                        ),
                        RouteDeclaration.routeBuilder(
                          route: _Routes2.innerBLeafB,
                          routeBuilder: RouteBuilder.widget(
                            builder: (_, __) => const Text('tabBInnerBLeafB'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ).build();
    addTearDown(config.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: config));

    final stateManager = config.routerDelegate.stateManager;
    stateManager.mutate((root) {
      final rootRoute = root.findByRoute(_Routes.tabHost);
      if (rootRoute == null) {
        return root;
      }

      rootRoute.setChildren([
        _Routes.tabA.toNode(
          children: [
            _Routes.tabANodeA.toNode(
              children: [
                _Routes.tabANodeALeafA.toNode(),
                _Routes.tabANodeALeafB.toNode(),
              ],
            ),
            _Routes.tabANodeB.toNode(
              children: [
                _Routes.tabANodeBLeafA.toNode(),
                _Routes.tabANodeBLeafB.toNode(),
              ],
            ),
          ],
        ),
        _Routes.tabB.toNode(
          children: [
            _Routes2.nestedList.toNode(),
            _Routes2.nestedIndexedStack.toNode(
              children: [
                _Routes2.innerTabA.toNode(
                  children: [
                    _Routes2.innerTabALeafA.toNode(),
                    _Routes2.innerTabALeafB.toNode(),
                  ],
                ),
                _Routes2.innerTabB.toNode(
                  children: [
                    _Routes2.innerBLeafA.toNode(),
                    _Routes2.innerBLeafB.toNode(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ]);
      return root;
    });
    await tester.pumpAndSettle();

    expect(find.text('tabBInnerBLeafB'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final tabB = stateManager.state.findByRoute(_Routes.tabB);
    final nestedIndexedStack =
        stateManager.state.findByRoute(_Routes2.nestedIndexedStack);
    final innerTabA = stateManager.state.findByRoute(_Routes2.innerTabA);
    final innerTabB = stateManager.state.findByRoute(_Routes2.innerTabB);

    expect(
      tabB?.children.map((node) => node.route),
      orderedEquals([_Routes2.nestedList, _Routes2.nestedIndexedStack]),
    );
    expect(
      nestedIndexedStack?.children.map((node) => node.route),
      orderedEquals([_Routes2.innerTabA, _Routes2.innerTabB]),
    );
    expect(
      innerTabA?.children.map((node) => node.route),
      orderedEquals([_Routes2.innerTabALeafA, _Routes2.innerTabALeafB]),
    );
    expect(
      innerTabB?.children.map((node) => node.route),
      orderedEquals([_Routes2.innerBLeafA]),
    );
    expect(find.text('tabBInnerBLeafA'), findsOneWidget);
    expect(find.text('tabBInnerBLeafB'), findsNothing);
  });
}
