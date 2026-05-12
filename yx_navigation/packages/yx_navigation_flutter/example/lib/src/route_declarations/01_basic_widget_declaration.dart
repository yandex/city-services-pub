// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'common/simple_page.dart';

/// Example 1: Basic declaration with RouteBuilder.widget.
///
/// Shows the simplest usage of RouteDeclaration.routeBuilder with
/// RouteBuilder.widget to describe regular pages.
///
/// Navigation structure:
/// ```
/// Home
///   -> Profile
///   -> Settings
///   -> About
/// ```
///
/// Key concepts:
/// - RouteDeclaration.routeBuilder with RouteBuilder.widget
/// - Basic push / pop navigation
/// - Minimal schema with several routes
void main() {
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));
  runApp(const BasicWidgetDeclarationApp());
}

/// App routes.
abstract class AppRoutes {
  static const home = YxRoute(id: 'home');
  static const profile = YxRoute(id: 'profile');
  static const settings = YxRoute(id: 'settings');
  static const about = YxRoute(id: 'about');
}

/// Home page declaration.
///
/// Uses RouteBuilder.widget to describe a simple page.
/// This is the most basic way to say which widget to render for a route.
final homeDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.home,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Home',
      nextRoutes: const [
        AppRoutes.profile,
        AppRoutes.settings,
        AppRoutes.about,
      ],
      backgroundColor: Colors.blue[50],
    ),
  ),
);

/// Profile page declaration.
final profileDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.profile,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Driver profile',
      backgroundColor: Colors.green[50],
    ),
  ),
);

/// Settings page declaration.
final settingsDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.settings,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Settings',
      backgroundColor: Colors.orange[50],
    ),
  ),
);

/// "About" page declaration.
final aboutDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.about,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'About',
      backgroundColor: Colors.purple[50],
    ),
  ),
);

/// App navigation schema.
///
/// Bundles every declaration together and sets the initial state.
class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema();

  @override
  List<RouteDeclaration> get declarations => [
        homeDeclaration,
        profileDeclaration,
        settingsDeclaration,
        aboutDeclaration,
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([AppRoutes.home.toNode()]);
}

class BasicWidgetDeclarationApp extends StatefulWidget {
  const BasicWidgetDeclarationApp({super.key});

  @override
  State<BasicWidgetDeclarationApp> createState() =>
      _BasicWidgetDeclarationAppState();
}

class _BasicWidgetDeclarationAppState extends State<BasicWidgetDeclarationApp> {
  late YxRouterConfig config;

  @override
  void initState() {
    super.initState();

    // Build the navigation schema and grab the router configuration.
    final schema = AppNavigationSchema();
    config = schema.build(
      debugConfiguration: NavigationDebugConfiguration(
        debugPanelModeNotifier: DebugPanelModeNotifier(
          enableDebugPanel: true,
          isInitiallyVisible: true,
        ),
        defaultDisplayType: DebugPanelDisplayType.splitTrailing,
      ),
    );
  }

  @override
  void dispose() {
    config.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Example 1: Basic declaration',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: config,
      );
}
