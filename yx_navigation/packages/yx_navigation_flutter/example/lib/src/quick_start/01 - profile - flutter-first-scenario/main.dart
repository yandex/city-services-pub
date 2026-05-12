import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'profile_navigation_schema.dart';

/// Entry point for the driver-profile navigation demo.
void main() {
  // Configure URL strategy for the web target.
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));

  runApp(const ProfileApp());
}

/// Demo app for the driver profile.
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

    // Create a debug panel notifier with the panel enabled.
    debugPanelModeNotifier = DebugPanelModeNotifier(enableDebugPanel: true);

    // Build the navigation schema and the router configuration.
    final profileSchema = ProfileNavigationSchema();
    config = profileSchema.build(
      debugConfiguration: NavigationDebugConfiguration(
        debugPanelModeNotifier: debugPanelModeNotifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Driver profile - Flutter First',
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
}
