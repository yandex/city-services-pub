import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'driver_navigation_schema.dart';

/// Entry point for the RouteDeclaration.scheme demo with the driver app.
void main() {
  // Configure URL strategy for the web target.
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));

  runApp(const DriverApp());
}

/// Driver app that showcases RouteDeclaration.scheme.
///
/// This app demonstrates:
/// - How to build the main navigation schema
/// - How to mount a nested schema via RouteDeclaration.scheme
/// - How to reuse existing features (ProfileNavigationSchema)
/// - A Flutter-first approach to navigation
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

    // Build the driver-app navigation schema. It contains:
    // - Top-level app routes (login, home, orders, messages)
    // - A nested profile schema via RouteDeclaration.scheme
    final driverSchema = DriverNavigationSchema();
    config = driverSchema.build(
      debugConfiguration: NavigationDebugConfiguration(
        debugPanelModeNotifier: debugPanelModeNotifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: config,
        title: 'Driver app - Schema Declaration',
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
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.deepPurple[50],
            selectedItemColor: Colors.deepPurple[700],
            unselectedItemColor: Colors.grey[600],
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
