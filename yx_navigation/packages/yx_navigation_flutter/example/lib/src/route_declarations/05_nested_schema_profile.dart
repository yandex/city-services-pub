// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

// Reuse the profile schema from the quick-start examples.
import '../quick_start/01 - profile - flutter-first-scenario/profile_navigation_schema.dart';
import 'common/simple_page.dart';

/// Example 5: Nested schema with RouteDeclaration.scheme.
///
/// Shows how to mount a pre-built profile schema as a nested schema
/// inside the host application.
///
/// Navigation structure:
/// ```
/// Main App
///   Home
///     -> Orders
///     -> Profile (Nested Schema)
///       ProfileNavigationSchema
///         - Profile Home
///         - Driver Profile
///         - Trips History
///         - Statistics
///         - Settings
///         - Documents
/// ```
///
/// Key concepts:
/// - RouteDeclaration.scheme mounts a pre-built schema
/// - A dedicated NavigationController.node is created
/// - outletBuilder lets you wrap the schema (for example in a Scope)
/// - The schema runs independently from the host app
void main() {
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));
  runApp(const NestedSchemaApp());
}

/// Host-app routes.
abstract class AppRoutes {
  static const home = YxRoute(id: 'main-home');
  static const homeContent = YxRoute(id: 'main-home-content');
  static const orders = YxRoute(id: 'main-orders');
  static const profile = YxRoute(id: 'main-profile');
}

/// Orders declaration.
final ordersDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.orders,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Orders',
      backgroundColor: Colors.green.shade50,
    ),
  ),
);

/// Profile declaration as a nested schema.
///
/// RouteDeclaration.scheme:
/// - Creates a nested Navigator for ProfileNavigationSchema
/// - Isolates the profile's navigation state
/// - outletBuilder lets you wrap the schema in an extra widget
final profileSchemaDeclaration = RouteDeclaration.scheme(
  route: AppRoutes.profile,
  schema: ProfileNavigationSchema(),
  // outletBuilder wraps the nested schema's outlet.
  // For example you can add an InheritedWidget here to pass data in.
  outletBuilder: (context, routeNode, outlet) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blue, width: 2),
    ),
    child: Column(
      children: [
        Container(
          color: Colors.blue.shade100,
          padding: const EdgeInsets.all(8),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16),
              SizedBox(width: 8),
              Text(
                'This is the nested ProfileNavigationSchema',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(child: outlet),
      ],
    ),
  ),
);

/// Home declaration with an outlet.
final homeDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.home,
  routeBuilder: RouteBuilder.outlet(
    outletBuilder: (context, routeNode, outlet) => Scaffold(
      appBar: AppBar(
        title: const Text('Host app'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nested schema'),
                  content: const Text(
                    'ProfileNavigationSchema is mounted as a nested schema.\n\n'
                    '- Isolated navigation state\n'
                    '- Dedicated Navigator\n'
                    '- Reusable architecture\n'
                    '- Independent development',
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
      body: outlet,
    ),
  ),
  declarations: [
    RouteDeclaration.routeBuilder(
      route: AppRoutes.homeContent,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => SimplePage(
          title: 'Home',
          nextRoutes: const [
            AppRoutes.orders,
            AppRoutes.profile,
          ],
          backgroundColor: Colors.blue.shade50,
        ),
      ),
    ),
    ordersDeclaration,
    profileSchemaDeclaration, // Nested schema
  ],
);

/// Host-app navigation schema.
base class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema();

  @override
  List<RouteDeclaration> get declarations => [
        homeDeclaration,
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) => node.copyWith(
        children: [
          AppRoutes.home.toNode(
            children: [
              AppRoutes.homeContent.toNode(),
            ],
          ),
        ],
      );
}

class NestedSchemaApp extends StatefulWidget {
  const NestedSchemaApp({super.key});

  @override
  State<NestedSchemaApp> createState() => _NestedSchemaAppState();
}

class _NestedSchemaAppState extends State<NestedSchemaApp> {
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
        title: 'Example 5: Nested schema',
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
