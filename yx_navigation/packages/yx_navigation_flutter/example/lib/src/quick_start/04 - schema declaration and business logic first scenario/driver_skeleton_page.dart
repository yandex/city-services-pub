import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'driver_app_dependencies.dart';
import 'driver_navigation_interactor.dart';
import 'driver_routes.dart';

/// Base skeleton page for the driver-app demo
/// (scenario 04 - Schema Declaration + Business Logic First).
///
/// Unlike scenario 03, this page resolves dependencies through Dependencies
/// and uses DriverNavigationInteractor instead of calling
/// YxNavigation.navigatorOf(context) directly.
class DriverSkeletonPage extends StatefulWidget {
  const DriverSkeletonPage({
    required this.title,
    required this.icon,
    this.nextRoutes = const [],
    this.description,
    super.key,
  });

  final String title;
  final IconData icon;
  final Iterable<YxRoute> nextRoutes;

  final String? description;

  @override
  State<DriverSkeletonPage> createState() => _DriverSkeletonPageState();
}

class _DriverSkeletonPageState extends State<DriverSkeletonPage> {
  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 32, color: Colors.deepPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                ),
              ),
            ],
          ),
          if (widget.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ],
      );

  Widget _buildNavigationSection(DriverNavigationInteractor driverInteractor) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Navigation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.nextRoutes
                    .map(
                      (route) => ElevatedButton(
                        onPressed: () =>
                            _navigateToRoute(route, driverInteractor),
                        child: Text(_getRouteDisplayName(route)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );

  Widget _buildBusinessLogicSection(driverInteractor) => Card(
        color: Colors.deepPurple.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business logic demo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Navigation is driven through DriverNavigationInteractor:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );

  Widget _buildApproachInfo() => Card(
        color: Colors.amber.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Combined approach',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '- Schema Declaration - profile as a nested schema\n'
                '- Business Logic First - navigation through the interactor\n'
                '- Feature Controller - isolated profile navigation',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.amber.shade800,
                    ),
              ),
            ],
          ),
        ),
      );

  void _navigateToRoute(
    YxRoute route,
    DriverNavigationInteractor driverInteractor,
  ) {
    // Use DriverNavigationInteractor methods instead of calling
    // routeNavigator.push() directly.
    switch (route) {
      case DriverRoutes.home:
        driverInteractor.openHome();
        break;
      case DriverRoutes.orders:
        driverInteractor.openOrders();
        break;
      case DriverRoutes.messages:
        driverInteractor.openMessages();
        break;
      case DriverRoutes.profile:
        driverInteractor.openProfile();
        break;
      default:
        // Fallback for unknown routes.
        YxNavigation.navigatorOf(context).push(route);
    }
  }

  String _getRouteDisplayName(YxRoute route) {
    switch (route) {
      case DriverRoutes.login:
        return 'Sign in';
      case DriverRoutes.home:
        return 'Home';
      case DriverRoutes.orders:
        return 'Orders';
      case DriverRoutes.messages:
        return 'Messages';
      case DriverRoutes.profile:
        return 'Profile';
      default:
        return route.id;
    }
  }

  void _showNavigationInfo(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigation info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Approach: Schema Declaration + Business Logic First'),
            const SizedBox(height: 8),
            Text('Can pop: ${routeNavigator.canPop() ? "Yes" : "No"}'),
            const SizedBox(height: 8),
            Text('Current page: ${widget.title}'),
            const SizedBox(height: 8),
            const Text('Ownership:'),
            const Text('- DriverApp -> DriverNavigationInteractor'),
            const Text('- Profile -> ProfileFeatureNavigationController'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Resolve dependencies from the DI container.
    final dependencies = DriverAppDependenciesScope.of(context);
    final driverInteractor = dependencies.driverInteractor;

    // Some UI bits still reach into YxNavigation directly.
    final routeNavigator = YxNavigation.navigatorOf(context);
    final canPop = routeNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.icon, size: 24),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leadingWidth: 100,
        leading: SizedBox(
          height: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: canPop ? 'Back' : 'Exit',
                icon: canPop
                    ? const Icon(Icons.arrow_back)
                    : const Icon(Icons.close),
                onPressed: canPop ? driverInteractor.goBack : null,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showNavigationInfo(context),
            tooltip: 'Navigation info',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading and description.
            _buildHeader(),
            const SizedBox(height: 24),

            // Navigation buttons.
            if (widget.nextRoutes.isNotEmpty) ...[
              _buildNavigationSection(driverInteractor),
              const SizedBox(height: 24),
            ],

            // Business-logic controls.
            _buildBusinessLogicSection(driverInteractor),
            const SizedBox(height: 24),

            // Info about the approach.
            _buildApproachInfo(),
          ],
        ),
      ),
    );
  }
}
