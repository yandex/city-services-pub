import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'profile_feature_dependencies.dart';
import 'profile_navigation_schema.dart';

/// Entry point showing the profile feature running in standalone mode.
///
/// This file illustrates how the profile feature can run independently of
/// a host application by using its own RouteNodeStateManager.
void main() {
  // Configure URL strategy for the web target.
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));

  // Demo: build dependencies for the business-logic walkthrough.
  final dependencies = ProfileFeatureDependencies.standalone();
  _demonstrateStandaloneFeatureNavigation(dependencies);

  // Use the smart constructor that builds the dependencies for us.
  runApp(
    ProfileFeatureDependenciesScope.standalone(
      child: const StandaloneProfileFeatureApp(),
    ),
  );
}

/// Demo of driving the feature's navigation from business logic before the UI exists.
void _demonstrateStandaloneFeatureNavigation(
  ProfileFeatureDependencies dependencies,
) {
  print('Standalone Profile Feature Demo: the feature runs independently.');
  print('Mode: ${dependencies.isStandalone ? "Standalone" : "Embedded"}');

  // Business logic can invoke navigation methods directly.
  final interactor = dependencies.profileInteractor;

  if (dependencies.stateManager != null) {
    print('Feature navigation state: ${dependencies.stateManager!.state}');
    print('Can pop: ${interactor.canPop()}');
  }
}

/// Standalone app for the profile feature.
class StandaloneProfileFeatureApp extends StatefulWidget {
  const StandaloneProfileFeatureApp({super.key});

  @override
  State<StandaloneProfileFeatureApp> createState() =>
      _StandaloneProfileFeatureAppState();
}

class _StandaloneProfileFeatureAppState
    extends State<StandaloneProfileFeatureApp> {
  late YxRouterConfig config;
  late DebugPanelModeNotifier debugPanelModeNotifier;

  @override
  void initState() {
    super.initState();

    // Debug panel notifier with the panel enabled.
    debugPanelModeNotifier = DebugPanelModeNotifier(enableDebugPanel: true);

    // In standalone mode we own the feature's state manager.
    final dependencies =
        ProfileFeatureDependenciesScope.of(context, listen: false);
    final stateManager =
        dependencies.stateManager!; // Always present in standalone mode.

    print('\nProfile feature UI initialization:');
    print('Using the feature-owned RouteNodeStateManager');
    print('The feature is running in standalone mode');

    // Build the navigation schema with the pre-built state manager.
    final profileSchema = ProfileNavigationSchema();
    config = profileSchema.build(
      stateManagerConfiguration: StateManagerConfiguration(
        stateManager: stateManager,
      ),
      debugConfiguration: NavigationDebugConfiguration(
        debugPanelModeNotifier: debugPanelModeNotifier,
        // Show the debug panel for the demo.
        defaultDisplayType: DebugPanelDisplayType.splitTrailing,
      ),
      navigatorConfiguration: NavigatorConfiguration(
        navigatorBuilder: (context, outlet) => Column(
          children: [
            // Demo controls that drive feature business logic.
            _buildFeatureBusinessLogicControls(context),
            // The feature's main content.
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple,
                    width: 3,
                  ),
                ),
                child: outlet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Profile Feature - Standalone Mode',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: config,
      );

  @override
  void dispose() {
    config.dispose();
    super.dispose();
  }

  Widget _buildFeatureBusinessLogicControls(BuildContext context) {
    final dependencies = ProfileFeatureDependenciesScope.of(context);
    final interactor = dependencies.profileInteractor;

    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Profile Feature - Standalone Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The feature runs independently with its own RouteNodeStateManager',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildControlButton(
                  'Profile',
                  () => interactor.openDriverProfile(),
                ),
                _buildControlButton(
                  'History',
                  () => interactor.openTripsHistory(),
                ),
                _buildControlButton(
                  'Statistics',
                  () => interactor.openStatistics(),
                ),
                _buildControlButton(
                  'Settings',
                  () => interactor.openSettings(),
                ),
                _buildControlButton(
                  'Documents',
                  () => interactor.openDocuments(),
                ),
                _buildControlButton(
                  'Feature home',
                  () => interactor.goToProfileHome(),
                  color: Colors.green,
                ),
                _buildControlButton(
                  'Back',
                  interactor.canPop() ? () => interactor.goBack() : null,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    String title,
    VoidCallback? onPressed, {
    Color? color,
  }) =>
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(title, style: const TextStyle(fontSize: 12)),
      );
}
