/// Demonstrates Compatibility Mode in YxNavigation.
///
/// Shows Navigator 1.0 API (imperative navigation) running inside an
/// app that uses YxNavigation's declarative (Navigator 2.0) navigation.
///
/// Highlights:
/// - push/pop with MaterialPageRoute and CupertinoPageRoute
/// - pushReplacement and pushAndRemoveUntil
/// - showDialog, showCupertinoDialog, showModalBottomSheet
/// - Receiving results from pop
/// - Mixing page-based and pageless routes
///
/// Warning: without NavigatorCompatibilityOverrides, replace operations
/// will trigger an assert.
///
/// Navigation structure:
/// ```
/// +---------------------------------------------------------+
/// | Root (YxNavigation)                                     |
/// |  +----------------------------------------------------+ |
/// |  | Home (Compatibility Demo)                          | |
/// |  |  - Push Material/Cupertino Routes                  | |
/// |  |  - PushReplacement, PushAndRemoveUntil             | |
/// |  |  - ShowDialog, ShowModalBottomSheet                | |
/// |  +----------------------------------------------------+ |
/// |  +----------------------------------------------------+ |
/// |  | Profile (Page-based for comparison)                | |
/// |  +----------------------------------------------------+ |
/// |  +----------------------------------------------------+ |
/// |  | Legacy Detail Pages (Pageless routes)              | |
/// |  |  - Created via Navigator.of(context).push()        | |
/// |  |  - Wrapped into a Page through Compatibility       | |
/// |  +----------------------------------------------------+ |
/// +---------------------------------------------------------+
/// ```
library;

import 'package:flutter/material.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter_compatibility.dart';

import 'compatibility_observers.dart';
import 'navigation_schema.dart';

void main() {
  runApp(const CompatibilityDemoApp());
}

class CompatibilityDemoApp extends StatefulWidget {
  const CompatibilityDemoApp({super.key});

  @override
  State<CompatibilityDemoApp> createState() => _CompatibilityDemoAppState();
}

class _CompatibilityDemoAppState extends State<CompatibilityDemoApp> {
  late YxRouterConfig config;

  // Keep observers as fields so we can call their methods directly.
  final debugObserver = DebugCompatibilityObserver();
  final migrationObserver = MigrationTrackingObserver();

  late final compatibilityObserver = CompositeCompatibilityObserver([
    debugObserver,
    migrationObserver,
  ]);

  @override
  void initState() {
    super.initState();

    // Create the navigation schema.
    final schema = CompatibilityNavigationSchema();

    // Create a debug panel notifier with the panel visible by default
    // in splitTrailing mode.
    final debugPanelModeNotifier = DebugPanelModeNotifier(
      enableDebugPanel: true,
      isInitiallyVisible: true,
    );

    // Build the RouterConfig with the debug panel pinned on the trailing side.
    config = schema.build(
      debugConfiguration: NavigationDebugConfiguration(
        debugPanelModeNotifier: debugPanelModeNotifier,
        defaultDisplayType: DebugPanelDisplayType.splitTrailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => NavigationConfigProvider(
        // Key point: enable NavigatorCompatibilityOverrides.
        //
        // Without it:
        // - pushReplacement triggers an assert
        // - pushAndRemoveUntil does not work
        // - showDialog / showModalBottomSheet do not integrate correctly
        //
        // With NavigatorCompatibilityOverrides:
        // - All Navigator 1.0 operations behave correctly
        // - Pageless routes are wrapped in a Page
        // - Navigation state stays consistent
        //
        // Observers (through CompositeCompatibilityObserver):
        // - DebugCompatibilityObserver logs every pageless-route event
        // - MigrationTrackingObserver collects route-type stats
        navigatorOverrides: NavigatorCompatibilityOverrides(
          observer: compatibilityObserver,
        ),
        child: MaterialApp.router(
          title: 'Compatibility Mode Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: false,
            ),
          ),
          debugShowCheckedModeBanner: false,
          routerConfig: config,
        ),
      );

  @override
  void dispose() {
    // Print the migration report before tearing down.
    migrationObserver.printReport();

    config.dispose();
    super.dispose();
  }
}
