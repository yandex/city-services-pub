import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'feature_a/feature_a_schema.dart';
import 'feature_b/feature_b_schema.dart';
import 'host_routes.dart';

/// Example demonstrating isolated schemas with different hierarchy validation settings.
///
/// This example shows how different teams can independently choose
/// their validation level:
/// - Feature A: Regular RouteDeclaration.routeBuilder() (flexible, experimental)
/// - Feature B: RouteDeclaration.strict() (strict, production-ready)
/// - Host: RouteDeclaration.strict() (strict validation)
///
/// Each schema validates independently without affecting others.
void main() {
  runApp(const StrictHierarchyExampleApp());
}

class StrictHierarchyExampleApp extends StatefulWidget {
  const StrictHierarchyExampleApp({super.key});

  @override
  State<StrictHierarchyExampleApp> createState() =>
      _StrictHierarchyExampleAppState();
}

class _StrictHierarchyExampleAppState extends State<StrictHierarchyExampleApp> {
  late YxRouterConfig config;

  @override
  void initState() {
    super.initState();
    config = _buildHostSchema().build(
      stateManagerConfiguration: StateManagerConfiguration(
        guardObserver: ExampleGuardObserver(),
        stateManagerObserver: ExampleStateManagerObserver(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Strict Hierarchy Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: config,
      );

  @override
  void dispose() {
    config.dispose();
    super.dispose();
  }

  RouterSchema _buildHostSchema() => HostNavigationSchema();
}

final class HostNavigationSchema extends RouterSchema {
  HostNavigationSchema();

  @override
  Iterable<RouteDeclaration> get declarations => [
        RouteDeclaration.strict(
          route: HostRoutes.home,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) => const HomePage(),
          ),
          declarations: const [],
          // Host root declarations use strict validation
          // Note: HostRoutes.home is not a nested outlet, so push operations
          // to featureA/B add them to the parent node (root), not to HostRoutes.home node
        ),
        // Feature A schema without strict hierarchy
        RouteSchemaDeclaration(
          route: HostRoutes.featureA,
          schema: FeatureASchema(),
        ),
        // Feature B schema with strict hierarchy
        RouteSchemaDeclaration(
          route: HostRoutes.featureB,
          schema: FeatureBSchema(),
        ),
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode root) => root.copyWith(
        children: [HostRoutes.home.toNode()],
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigator = YxNavigation.navigatorOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strict Hierarchy Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose a feature to explore:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => navigator.push(HostRoutes.featureA),
              icon: const Icon(Icons.science),
              label: const Text('Feature A (No Strict Hierarchy)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Experimental feature, flexible validation',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => navigator.push(HostRoutes.featureB),
              icon: const Icon(Icons.verified),
              label: const Text('Feature B (Strict Hierarchy)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Production feature, strict validation',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              '💡 Go to Feature B to test strict hierarchy validation',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExampleGuardObserver extends GuardObserver {
  @override
  void onGuardError(
    RouteNode origin,
    RouteNode target,
    Object error,
    StackTrace stackTrace,
    RouteNodeGuard guard,
  ) {
    super.onGuardError(origin, target, error, stackTrace, guard);
    print('🔴 Guard error: $error');
    print('   Guard: ${guard.runtimeType}');
  }
}

class ExampleStateManagerObserver extends StateManagerObserver {
  @override
  void onMutation(BaseStateManager stateManager, Mutation mutation) {
    super.onMutation(stateManager, mutation);
    print('🔵 Navigation mutation');
    print('   From: ${_getRoutesDescription(mutation.originalState)}');
    print('   To:   ${_getRoutesDescription(mutation.targetState)}');
  }

  @override
  void onError(
    BaseStateManager stateManager,
    Object error,
    StackTrace stackTrace,
  ) {
    super.onError(stateManager, error, stackTrace);
    print('❌ State manager error: $error');
  }

  String _getRoutesDescription(RouteNode node) {
    final routes = <String>[];
    _collectRoutes(node, routes, '');
    return routes.join(', ');
  }

  void _collectRoutes(RouteNode node, List<String> routes, String indent) {
    routes.add(node.route.id);
    for (final child in node.children) {
      _collectRoutes(child, routes, '$indent  ');
    }
  }
}
