import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'feature_a_routes.dart';

/// Builds Feature A schema with strictHierarchy = false.
///
/// This feature is experimental and doesn't enforce strict validation.
/// Teams can navigate freely without declaration constraints.
final class FeatureASchema extends RouterSchema {
  FeatureASchema();

  @override
  Iterable<RouteDeclaration> get declarations => [
        RouteDeclaration.routeBuilder(
          route: FeatureARoutes.home,
          routeBuilder: RouteBuilder.outlet(
            outletBuilder: (context, routeNode, outlet) => FeatureAHomePage(
              child: outlet,
            ),
          ),
          declarations: [], // No child declarations - flexible navigation
        ),
        // These routes are declared at schema level, but NOT as child declarations of home
        RouteDeclaration.routeBuilder(
          route: FeatureARoutes.details,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) => const FeatureADetailsPage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: FeatureARoutes.settings,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) => const FeatureASettingsPage(),
          ),
        ),
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode root) => root.copyWith(
        children: [FeatureARoutes.home.toNode()],
      );
}

class FeatureAHomePage extends StatelessWidget {
  const FeatureAHomePage({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final navigator = YxNavigation.navigatorOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature A - Home'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Default content
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.science, size: 64, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  'Feature A (Experimental)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'This feature has strictHierarchy = false.\n'
                    'Navigation is flexible - any route can be opened.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => navigator.push(FeatureARoutes.details),
                  child: const Text('Go to Details'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => navigator.push(FeatureARoutes.settings),
                  child: const Text('Go to Settings'),
                ),
              ],
            ),
          ),
          // Outlet for nested routes
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class FeatureADetailsPage extends StatelessWidget {
  const FeatureADetailsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Feature A - Details'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, size: 64, color: Colors.orange),
              SizedBox(height: 24),
              Text(
                'Details Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
}

class FeatureASettingsPage extends StatelessWidget {
  const FeatureASettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Feature A - Settings'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 64, color: Colors.orange),
              SizedBox(height: 24),
              Text(
                'Settings Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
}
