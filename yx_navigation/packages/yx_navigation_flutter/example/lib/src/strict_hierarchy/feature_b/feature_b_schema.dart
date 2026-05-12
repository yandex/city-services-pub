import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'feature_b_routes.dart';

/// Builds Feature B schema with strict hierarchy validation.
///
/// This feature is production-ready and enforces strict validation.
/// All navigation must follow declared hierarchy.
final class FeatureBSchema extends RouterSchema {
  FeatureBSchema();

  @override
  Iterable<RouteDeclaration> get declarations => [
        RouteDeclaration.strict(
          route: FeatureBRoutes.root,
          routeBuilder: RouteBuilder.outlet(
            outletBuilder: (_, __, outlet) => outlet,
          ),
          declarations: [
            RouteDeclaration.strict(
              route: FeatureBRoutes.home,
              routeBuilder: RouteBuilder.widget(
                builder: (context, node) => const FeatureBHomePage(),
              ),
              declarations: const [],
            ),
            RouteDeclaration.strict(
              route: FeatureBRoutes.dashboard,
              routeBuilder: RouteBuilder.outlet(
                outletBuilder: (_, __, outlet) => FeatureBDashboardPage(
                  outlet: outlet,
                ),
              ),
              declarations: [
                // This declaration should not be allowed in Home page
                // and will throw AssertionError in debug mode in attempt to navigate to it
                // But it is available in Dashboard page
                //
                // See more details using GuardObserver
                RouteDeclaration.routeBuilder(
                  route: FeatureBRoutes.inNotAlloweInHome,
                  routeBuilder: RouteBuilder.widget(
                    builder: (context, node) =>
                        const FeatureBRestrictablePage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode root) => root.copyWith(
        children: [
          FeatureBRoutes.root.toNode(
            children: [
              FeatureBRoutes.home.toNode(),
            ],
          ),
        ],
      );
}

class FeatureBHomePage extends StatelessWidget {
  const FeatureBHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final navigator = YxNavigation.navigatorOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature B - Home'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, size: 64, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Feature B (Production)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This feature uses RouteDeclaration.strict().\n'
                'All navigation is validated against declarations.\n'
                'Invalid navigation triggers StateError.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => navigator.push(FeatureBRoutes.dashboard),
              child: const Text('Go to Dashboard (✅ Declared)'),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Try this:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => navigator.push(FeatureBRoutes.inNotAlloweInHome),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Go to FeatureBRoutes.inNotAlloweInHome (❌ Will throw StateError)',
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'This will trigger StateError\n'
                'because "FeatureBRoutes.inNotAlloweInHome" is not declared '
                'in inner declarations of Home page',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureBDashboardPage extends StatelessWidget {
  final Widget outlet;

  const FeatureBDashboardPage({
    required this.outlet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final navigator = YxNavigation.navigatorOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature B - Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 64, color: Colors.green),
            SizedBox(height: 24),
            Text(
              'Dashboard Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '✅ This route is properly declared',
              style: TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => navigator.push(FeatureBRoutes.inNotAlloweInHome),
              child: const Text('Go to FeatureBRoutes.inNotAlloweInHome ✅ '),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'This will be allowed in Dashboard page\n'
                'because "FeatureBRoutes.inNotAlloweInHome" is declared '
                'in inner declarations of Dashboard page',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
            Divider(),
            Expanded(child: outlet),
          ],
        ),
      ),
    );
  }
}

class FeatureBRestrictablePage extends StatelessWidget {
  const FeatureBRestrictablePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Feature B - Reports'),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.green),
              SizedBox(height: 24),
              Text(
                'Reports Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '✅ This route is properly declared',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
      );
}
