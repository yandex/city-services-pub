import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'driver_app_dependencies.dart';
import 'driver_navigation_schema.dart';

/// Entry point that demonstrates the combined approach:
/// Schema Declaration + Business Logic First.
///
/// Covers:
/// - How to build a business-logic-first app with nested schemas
/// - How to drive navigation before the UI exists
/// - How to wire a profile-scoped NavigationController for a nested feature
/// - How to coordinate host and nested navigation
void main() {
  // Configure URL strategy for the web target.
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));

  // Build dependencies:
  // - DriverNavigationInteractor backed by the root RouteNodeStateManager
  // - A profile-scoped NavigationController targeting a subtree of the state
  final dependencies = DriverAppDependencies();

  // Demo: navigation is callable before MaterialApp is built.
  _demonstrateBusinessLogicNavigation(dependencies);

  runApp(
    DriverAppDependenciesScope(
      dependencies: dependencies,
      child: const DriverApp(),
    ),
  );
}

/// Shows navigation being driven from business logic before the UI exists.
///
/// Highlights the combined-approach capabilities:
/// - Driving the host-app navigation
/// - Driving the nested profile navigation
/// - Coordinating across levels
void _demonstrateBusinessLogicNavigation(DriverAppDependencies dependencies) {
  print('Schema Declaration + Business-Logic-First Demo:');
  print('   Combined navigation approach.');

  final driverInteractor = dependencies.driverInteractor;

  print('\nNavigation state:');
  print('Root state: ${driverInteractor.stateManager.state}');
  print('Can pop: ${driverInteractor.canPop()}');

  // Scheduled business-logic scenario: automatic jump to the profile.
  Timer(const Duration(seconds: 2), () {
    print('\nRunning business logic: sign-in flow...');
    driverInteractor.performLogin();
  });
}

/// Driver app that showcases the combined approach.
///
/// Highlights:
/// - Business Logic First - RouteNodeStateManager is built inside business logic
/// - Schema Declaration - the profile is a nested schema
/// - Feature Navigation Controller - isolated profile navigation
/// - Coordination between host and nested navigation
class DriverApp extends StatefulWidget {
  const DriverApp({super.key});

  @override
  State<DriverApp> createState() => _DriverAppState();
}

class _DriverAppState extends State<DriverApp> {
  late YxRouterConfig config;
  late DebugPanelModeNotifier debugPanelModeNotifier;

  @override
  void initState() {
    super.initState();

    // Debug panel notifier with the panel enabled.
    debugPanelModeNotifier = DebugPanelModeNotifier(enableDebugPanel: true);

    // With the combined approach:
    // 1. Read the prepared state manager from Dependencies (Business Logic First)
    // 2. Hand it to the schema that owns nested schemas (Schema Declaration)
    final dependencies = DriverAppDependenciesScope.of(context, listen: false);
    final stateManager = dependencies.stateManager;

    print('\nUI initialization:');
    print('Using the RouteNodeStateManager built by business logic');
    print('Schema contains the nested profile feature');

    // Build the driver-app navigation schema. It contains:
    // - Host-app routes (login, home, orders, messages)
    // - The nested profile schema via RouteDeclaration.scheme
    final driverSchema = DriverNavigationSchema();
    dependencies.routeNodeGuard.attach(
      'driverSchema',
      driverSchema.buildGuards(),
    );

    config = driverSchema.build(
      stateManagerConfiguration: StateManagerConfiguration(
        stateManager: stateManager,
      ),
      debugConfiguration: NavigationDebugConfiguration(
        debugPanelModeNotifier: debugPanelModeNotifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'DriverApp - Schema Declaration + Business Logic First',
        routerConfig: config,
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
      );

  @override
  void dispose() {
    config.dispose();
    super.dispose();
  }
}
