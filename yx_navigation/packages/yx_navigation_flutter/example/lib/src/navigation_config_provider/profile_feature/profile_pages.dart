import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'profile_routes.dart';

/// Base page for the driver-profile section.
class ProfileBasePage extends StatelessWidget {
  final String title;
  final List<YxRoute> availableRoutes;
  final String description;

  const ProfileBasePage({
    required this.title,
    required this.availableRoutes,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);
    final parentNavigator = YxNavigation.parentNavigatorOf(context);
    final canPop = routeNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: routeNavigator.pop,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver profile (nested schema)',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Navigation configuration can be overridden via NavigationConfigProvider',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (availableRoutes.isNotEmpty) ...[
              Text(
                'Available destinations:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ...availableRoutes.map(
                (route) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => routeNavigator.push(route),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_getRouteTitle(route)),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Widget showcase.
            Text(
              'Widget showcase:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.purple[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'These buttons showcase the overridden not-found and empty widgets inside the profile',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.purple[600],
                  ),
            ),
            const SizedBox(height: 16),
            // Button to demonstrate the Not Found widget.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to a non-existent profile route.
                  routeNavigator
                      .push(const YxRoute(id: 'profile-non-existent'));
                },
                icon: const Icon(Icons.error_outline),
                label: const Text('Navigate to a non-existent profile route'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Button to demonstrate the Empty widget.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  routeNavigator.push(ProfileRoutes.demoEmpty);
                },
                icon: const Icon(Icons.inbox_outlined),
                label: const Text('Show the empty profile widget'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.purple),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Button to exit the profile section.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: parentNavigator.maybePop,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Exit profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRouteTitle(YxRoute route) {
    switch (route.id) {
      case 'profile-home':
        return 'Profile home';
      case 'profile-driver':
        return 'Driver details';
      case 'profile-trips-history':
        return 'Trips history';
      case 'profile-statistics':
        return 'Statistics';
      case 'profile-settings':
        return 'Profile settings';
      case 'profile-documents':
        return 'Documents';
      default:
        return route.id;
    }
  }
}

/// Profile home page.
class ProfileHomePage extends StatelessWidget {
  const ProfileHomePage({super.key});

  @override
  Widget build(BuildContext context) => const ProfileBasePage(
        title: 'My profile',
        description: 'Welcome to your driver profile. '
            'Manage your profile, review statistics '
            'and tweak your working preferences here.',
        availableRoutes: [
          ProfileRoutes.driverProfile,
          ProfileRoutes.tripsHistory,
          ProfileRoutes.statistics,
          ProfileRoutes.settings,
          ProfileRoutes.documents,
        ],
      );
}

/// Driver details page.
class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) => const ProfileBasePage(
        title: 'Driver profile',
        description: 'View and edit driver details. '
            'Update contact information, profile photo '
            'and other personal data here.',
        availableRoutes: [
          ProfileRoutes.settings,
          ProfileRoutes.documents,
        ],
      );
}

/// Trips history page.
class TripsHistoryPage extends StatelessWidget {
  const TripsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) => const ProfileBasePage(
        title: 'Trips history',
        description: 'List of every completed order with detailed information '
            'for each trip: route, fare, completion time.',
        availableRoutes: [
          ProfileRoutes.statistics,
        ],
      );
}

/// Statistics page.
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) => const ProfileBasePage(
        title: 'Statistics',
        description: 'Analytics for earnings, ratings and productivity. '
            'Charts and reports over different time ranges.',
        availableRoutes: [
          ProfileRoutes.tripsHistory,
        ],
      );
}

/// Profile settings page.
class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const ProfileBasePage(
        title: 'Settings',
        description: 'Configure app preferences: '
            'notifications, order preferences, map settings.',
        availableRoutes: [
          ProfileRoutes.documents,
        ],
      );
}

/// Documents page.
class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) => const ProfileBasePage(
        title: 'Documents',
        description: 'Upload and manage documents: '
            'driver license, insurance, vehicle paperwork.',
        availableRoutes: [],
      );
}
