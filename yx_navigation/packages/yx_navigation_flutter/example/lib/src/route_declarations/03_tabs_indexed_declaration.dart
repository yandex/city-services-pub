// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'common/tab_page.dart';

/// Example 3: Tabs with RouteDeclaration.indexedStack.
///
/// Shows how to use RouteDeclaration.indexedStack to build tabs with
/// automatic state management.
///
/// Navigation structure:
/// ```
/// Home (IndexedStack)
///   TabBar: Map | Messages | Profile | Settings
///   Tab content (IndexedStack):
///     - Map page
///     - Messages page
///     - Profile page
///     - Settings page
/// ```
///
/// Key concepts:
/// - RouteDeclaration.indexedStack creates guards for children automatically
/// - RouteIndexedStackBuilder manages the IndexedStack
/// - ActiveRouteController switches the active tab
/// - Tabs preserve state across switches (Offstage + TickerMode)
void main() {
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));
  runApp(const TabsIndexedDeclarationApp());
}

/// App routes.
abstract class AppRoutes {
  static const home = YxRoute(id: 'home');
  static const map = YxRoute(id: 'map');
  static const messages = YxRoute(id: 'messages');
  static const profile = YxRoute(id: 'profile');
  static const settings = YxRoute(id: 'settings');
}

/// "Map" tab declaration.
final mapTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.map,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => const TabPage(
      title: 'Map',
      icon: Icons.map,
      backgroundColor: Colors.blue,
    ),
  ),
);

/// "Messages" tab declaration.
final messagesTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.messages,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => const TabPage(
      title: 'Messages',
      icon: Icons.message,
      backgroundColor: Colors.green,
    ),
  ),
);

/// "Profile" tab declaration.
final profileTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.profile,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => const TabPage(
      title: 'Profile',
      icon: Icons.person,
      backgroundColor: Colors.orange,
    ),
  ),
);

/// "Settings" tab declaration.
final settingsTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.settings,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => const TabPage(
      title: 'Settings',
      icon: Icons.settings,
      backgroundColor: Colors.purple,
    ),
  ),
);

/// Home declaration with an IndexedStack.
///
/// RouteDeclaration.indexedStack automatically:
/// - Wires guards to manage children
/// - Exposes ActiveRouteController for switching tabs
/// - Preserves state for each tab
final homeDeclaration = RouteDeclaration.indexedStack(
  route: AppRoutes.home,
  routeBuilder: RouteIndexedStackBuilder(
    indexedBuilder: (context, routeNode, indexedStack, controller) {
      // Read the current active route.
      final activeRoute = controller.activeRoute ?? AppRoutes.map;
      final tabs = [
        AppRoutes.map,
        AppRoutes.messages,
        AppRoutes.profile,
        AppRoutes.settings,
      ];
      final currentIndex = tabs.indexOf(activeRoute);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Driver app'),
        ),
        body: indexedStack, // IndexedStack hosting the tabs
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            // Switch the active route through the controller.
            controller.setActiveRoute(tabs[index]);
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    },
  ),
  // Nested declarations are the tabs themselves.
  // RouteDeclaration.indexedStack will wire guards for them.
  declarations: [
    mapTabDeclaration,
    messagesTabDeclaration,
    profileTabDeclaration,
    settingsTabDeclaration,
  ],
);

/// App navigation schema.
base class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema();

  @override
  List<RouteDeclaration> get declarations => [
        homeDeclaration,
      ];

  // Initial state: Home with every tab.
  // RouteDeclaration.indexedStack will build the children.
  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node.copyWith(children: [AppRoutes.home.toNode()]);
}

class TabsIndexedDeclarationApp extends StatefulWidget {
  const TabsIndexedDeclarationApp({super.key});

  @override
  State<TabsIndexedDeclarationApp> createState() =>
      _TabsIndexedDeclarationAppState();
}

class _TabsIndexedDeclarationAppState extends State<TabsIndexedDeclarationApp> {
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
        title: 'Example 3: Tabs with IndexedDeclaration',
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
