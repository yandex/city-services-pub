import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

// Profile routes for the feature.
import 'profile_routes.dart';

import 'profile_feature_dependencies.dart';
import 'profile_navigation_interactor.dart';

/// Skeleton page for the driver-profile demo
/// (scenario 04 - Schema Declaration + Business Logic First).
///
/// Unlike scenario 02, this page:
/// - Runs as part of the nested schema inside DriverApp
/// - Resolves ProfileNavigationInteractor via ProfileFeatureDependencies
/// - Demonstrates isolated navigation inside the feature
/// - Works in both standalone and embedded modes
class ProfileSkeletonPage extends StatefulWidget {
  const ProfileSkeletonPage({
    required this.title,
    this.nextRoutes = const [],
    super.key,
  });

  final String title;

  final Iterable<YxRoute> nextRoutes;

  @override
  State<ProfileSkeletonPage> createState() => _ProfileSkeletonPageState();
}

class _ProfileSkeletonPageState extends State<ProfileSkeletonPage> {
  Widget _buildHeader(ProfileFeatureDependencies dependencies) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 32, color: Colors.deepPurple),
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
          const SizedBox(height: 8),
          Text(
            'Driver profile page - ${dependencies.isStandalone ? 'Standalone' : 'Embedded'}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      );

  Widget _buildNavigationSection(
    ProfileNavigationInteractor profileInteractor,
  ) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile navigation',
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
                            _navigateToRoute(route, profileInteractor),
                        child: Text(_getRouteDisplayName(route)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );

  Widget _buildProfileControlsSection(
    ProfileNavigationInteractor profileInteractor,
  ) =>
      Card(
        color: Colors.deepPurple.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controls via ProfileNavigationInteractor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Navigation inside the profile is managed in isolation:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),

              // Core profile actions.
              Text(
                'Main sections:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: profileInteractor.openDriverProfile,
                    icon: const Icon(Icons.person, size: 16),
                    label: const Text('Profile'),
                  ),
                  ElevatedButton.icon(
                    onPressed: profileInteractor.openTripsHistory,
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('History'),
                  ),
                  ElevatedButton.icon(
                    onPressed: profileInteractor.openStatistics,
                    icon: const Icon(Icons.bar_chart, size: 16),
                    label: const Text('Statistics'),
                  ),
                  ElevatedButton.icon(
                    onPressed: profileInteractor.openSettings,
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Settings'),
                  ),
                  ElevatedButton.icon(
                    onPressed: profileInteractor.openDocuments,
                    icon: const Icon(Icons.description, size: 16),
                    label: const Text('Documents'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Demo flows.
              Text(
                'Demo flows:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );

  void _navigateToRoute(
    YxRoute route,
    ProfileNavigationInteractor profileInteractor,
  ) {
    // Delegate to ProfileNavigationInteractor.
    switch (route) {
      case ProfileRoutes.driverProfile:
        profileInteractor.openDriverProfile();
        break;
      case ProfileRoutes.tripsHistory:
        profileInteractor.openTripsHistory();
        break;
      case ProfileRoutes.statistics:
        profileInteractor.openStatistics();
        break;
      case ProfileRoutes.settings:
        profileInteractor.openSettings();
        break;
      case ProfileRoutes.documents:
        profileInteractor.openDocuments();
        break;
      default:
        // Fallback for unknown routes.
        YxNavigation.navigatorOf(context).push(route);
    }
  }

  String _getRouteDisplayName(YxRoute route) {
    switch (route) {
      case ProfileRoutes.home:
        return 'Home';
      case ProfileRoutes.driverProfile:
        return 'Driver profile';
      case ProfileRoutes.tripsHistory:
        return 'Trips history';
      case ProfileRoutes.statistics:
        return 'Statistics';
      case ProfileRoutes.settings:
        return 'Settings';
      case ProfileRoutes.documents:
        return 'Documents';
      default:
        return route.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve ProfileNavigationInteractor through DI.
    final dependencies = ProfileFeatureDependenciesScope.of(context);
    final profileInteractor = dependencies.profileInteractor;

    // UI-related checks still use the standard navigator.
    final routeNavigator = YxNavigation.navigatorOf(context);
    final canPop = routeNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                tooltip: 'Back',
                iconSize: 22,
                icon: canPop
                    ? const Icon(Icons.arrow_back)
                    : const Icon(Icons.close),
                onPressed: canPop ? profileInteractor.goBack : null,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading.
            _buildHeader(dependencies),
            const SizedBox(height: 24),

            // Navigation buttons (if any).
            if (widget.nextRoutes.isNotEmpty) ...[
              _buildNavigationSection(profileInteractor),
              const SizedBox(height: 24),
            ],

            // Control panel backed by ProfileNavigationInteractor.
            _buildProfileControlsSection(profileInteractor),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
