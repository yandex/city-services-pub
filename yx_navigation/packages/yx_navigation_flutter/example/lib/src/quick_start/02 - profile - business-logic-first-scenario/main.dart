import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'dependencies.dart';
import 'profile_navigation_schema.dart';

/// Entry point for the business-logic-first driver-profile demo.
void main() {
  // Configure URL strategy for the web target.
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));

  // Build dependencies. ProfileNavigationInteractor already owns a
  // RouteNodeStateManager seeded with the initial state.
  final dependencies = Dependencies();

  // Demo: navigation is callable before MaterialApp is even constructed.
  _demonstrateBusinessLogicNavigation(dependencies);

  runApp(
    DependenciesScope(
      dependencies: dependencies,
      child: const ProfileApp(),
    ),
  );
}

/// Shows navigation being driven from business logic before the UI exists.
void _demonstrateBusinessLogicNavigation(Dependencies dependencies) {
  print(
    'Business-Logic-First Demo: navigation is available before MaterialApp.',
  );

  // Business logic can invoke navigation methods directly.
  final interactor = dependencies.profileInteractor;

  print('Current navigation state: ${interactor.stateManager.state}');
  print('Can pop: ${interactor.canPop()}');

  // And drive navigation state from business logic.
  Timer(const Duration(seconds: 2), () {
    print('Running the scheduled navigation from business logic...');
    interactor.openDriverProfile();
  });
}

/// Demo app for the driver profile (business-logic-first variant).
class ProfileApp extends StatefulWidget {
  const ProfileApp({super.key});

  @override
  State<ProfileApp> createState() => _ProfileAppState();
}

class _ProfileAppState extends State<ProfileApp> {
  late YxRouterConfig config;
  late DebugPanelModeNotifier debugPanelModeNotifier;

  @override
  void initState() {
    super.initState();

    // Debug panel notifier with the panel enabled.
    debugPanelModeNotifier = DebugPanelModeNotifier(enableDebugPanel: true);

    // In the business-logic-first variant we pull the already-initialized
    // state manager from Dependencies.
    final stateManager =
        DependenciesScope.of(context, listen: false).stateManager;

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
            // Demo controls driving the business logic.
            _buildBusinessLogicControls(context),
            // The main app content.
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orange,
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
        title: 'Driver profile - Business Logic First',
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

  Widget _buildBusinessLogicControls(BuildContext context) {
    final dependencies = DependenciesScope.of(context);
    final interactor = dependencies.profileInteractor;

    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Profile Navigation Interactor operations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                  'Home',
                  () => interactor.goToHome(),
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
