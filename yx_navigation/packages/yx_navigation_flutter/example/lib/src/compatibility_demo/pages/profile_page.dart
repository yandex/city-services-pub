import 'package:flutter/material.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// Profile page demonstrating declarative navigation.
///
/// This page is declared via RouteDeclaration (page-based route)
/// as a direct counterpart to pageless routes.
class CompatibilityProfilePage extends StatelessWidget {
  const CompatibilityProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);
    final canPop = routeNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => routeNavigator.pop(),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route info
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.route, color: Colors.teal.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Route info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Type:', 'RouteDeclaration'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Mode:', 'Page-based Route'),
                    const SizedBox(height: 8),
                    _buildInfoRow('API:', 'YxNavigation (Navigator 2.0)'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Navigation:', 'routeNavigator.push/pop'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'This page is declared via RouteDeclaration:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                'RouteDeclaration.routeBuilder(\n'
                '  route: CompatibilityRoutes.profile,\n'
                '  routeBuilder: RouteBuilder.widget(\n'
                '    builder: (context, state) =>\n'
                '      CompatibilityProfilePage(),\n'
                '  ),\n'
                ');',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Comparison
            const Text(
              'Differences from pageless routes:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeature('-', 'Declared through RouteDeclaration'),
            _buildFeature(
              '-',
              'Visible in the state tree as part of the navigation schema',
            ),
            _buildFeature('-', 'Supports guards to gate navigation'),
            _buildFeature('-', 'Works with deep linking'),
            _buildFeature('-', 'Recommended for new code'),

            const Spacer(),

            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'In Compatibility mode you can mix page-based '
                        'and pageless routes in the same Navigator.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      );

  Widget _buildFeature(String bullet, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bullet,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
}
