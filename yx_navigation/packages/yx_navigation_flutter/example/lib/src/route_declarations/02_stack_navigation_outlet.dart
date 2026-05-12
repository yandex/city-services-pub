// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'common/simple_page.dart';

/// Example 2: Stack navigation with RouteBuilder.outlet.
///
/// Shows how to use RouteBuilder.outlet to create a nested navigator
/// (a page stack).
///
/// Navigation structure:
/// ```
/// Home (outlet)
///   Dashboard
///     -> Orders
///     -> Map
///     -> Messages
/// ```
///
/// Key concepts:
/// - RouteBuilder.outlet creates a nested Navigator
/// - NavigatorOutlet renders the child page stack
/// - Nested declarations define the routes available inside the outlet
/// - Every page in the stack can have its own navigation
void main() {
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));
  runApp(const StackNavigationApp());
}

/// App routes.
abstract class AppRoutes {
  static const home = YxRoute(id: 'home');
  static const dashboard = YxRoute(id: 'dashboard');
  static const orders = YxRoute(id: 'orders');
  static const map = YxRoute(id: 'map');
  static const messages = YxRoute(id: 'messages');
}

/// Dashboard declaration.
final dashboardDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.dashboard,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Dashboard',
      nextRoutes: const [
        AppRoutes.orders,
        AppRoutes.map,
        AppRoutes.messages,
      ],
      backgroundColor: Colors.blue[50],
    ),
  ),
);

/// Orders declaration.
final ordersDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.orders,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Orders',
      nextRoutes: const [AppRoutes.map],
      backgroundColor: Colors.green.shade50,
    ),
  ),
);

/// Map declaration.
final mapDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.map,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Map',
      nextRoutes: const [AppRoutes.messages],
      backgroundColor: Colors.amber.shade50,
    ),
  ),
);

/// Messages declaration.
final messagesDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.messages,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Messages',
      backgroundColor: Colors.purple[50],
    ),
  ),
);

/// Home declaration with a nested outlet.
///
/// RouteBuilder.outlet creates a NavigatorOutlet that renders the
/// child pages as a stack.
///
/// outletBuilder lets you wrap the outlet in an extra widget, for example
/// to provide a Scaffold with a shared AppBar.
final homeDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.home,
  routeBuilder: RouteBuilder.outlet(
    // Wrap the outlet in a Scaffold to share one AppBar.
    outletBuilder: (context, routeNode, outlet) => Scaffold(
      appBar: AppBar(
        title: const Text('Driver app'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Info'),
                  content: const Text(
                    'Navigation example with outlet.\n\n'
                    'An outlet creates a nested Navigator that renders '
                    'the page stack for you.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Info',
          ),
        ],
      ),
      body: outlet, // Nested navigator
    ),
  ),
  // Nested declarations - pages available inside the outlet.
  declarations: [
    dashboardDeclaration,
    ordersDeclaration,
    mapDeclaration,
    messagesDeclaration,
  ],
);

/// App navigation schema.
base class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema();

  @override
  List<RouteDeclaration> get declarations => [
        homeDeclaration,
      ];

  // Initial state: Home hosting Dashboard.
  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) => node.copyWith(
        children: [
          AppRoutes.home.toNode(
            children: [
              AppRoutes.dashboard.toNode(),
            ],
          ),
        ],
      );
}

class StackNavigationApp extends StatefulWidget {
  const StackNavigationApp({super.key});

  @override
  State<StackNavigationApp> createState() => _StackNavigationAppState();
}

class _StackNavigationAppState extends State<StackNavigationApp> {
  late YxRouterConfig config;

  @override
  void initState() {
    super.initState();

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
        title: 'Example 2: Stack navigation with Outlet',
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
