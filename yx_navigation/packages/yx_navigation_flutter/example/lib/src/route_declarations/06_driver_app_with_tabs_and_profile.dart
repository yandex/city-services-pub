// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import '../quick_start/01 - profile - flutter-first-scenario/profile_navigation_schema.dart';
import 'common/simple_page.dart';
import 'common/tab_page.dart';
import 'guards/tab_init_guard.dart';

/// Example 6: Driver app with a TabBar and a nested profile schema.
///
/// A richer example that combines:
/// - A root outlet for Home and Authentication
/// - A TabBar with a BottomNavigationBar (via RouteDeclaration.indexedStack)
/// - A nested profile schema in one of the tabs
///
/// Navigation structure:
/// ```
/// Root (outlet)
///   Home (IndexedStack - tabs)
///     TabBar: Map | Messages | Profile | Settings
///     - Map Tab
///     - Messages Tab (with nested navigation)
///     - Profile Tab (RouteDeclaration.scheme)
///         ProfileNavigationSchema
///           - Profile Home
///           - Driver Profile
///           - Trips History
///           - Statistics
///           - Settings
///           - Documents
///     - Settings Tab
///   Authentication
/// ```
///
/// Key concepts:
/// - Mixes every declaration type
/// - TabBar with a nested schema in a single tab
/// - Isolated profile navigation state
/// - A real-world driver-app scenario
void main() {
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));
  runApp(const DriverAppWithTabsApp());
}

/// App routes.
abstract class AppRoutes {
  static const root = YxRoute(id: 'root');
  static const home = YxRoute(id: 'home');
  static const authentication = YxRoute(id: 'authentication');

  // Tab routes
  static const mapTab = YxRoute(id: 'map-tab');
  static const messagesTab = YxRoute(id: 'messages-tab');
  static const profileTab = YxRoute(id: 'profile-tab');
  static const settingsTab = YxRoute(id: 'settings-tab');

  // Nested pages inside the Messages tab
  static const chatList = YxRoute(id: 'chat-list');
  static const chat = YxRoute(id: 'chat');
}

/// Authentication declaration.
final authDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.authentication,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Sign in',
      nextRoutes: const [AppRoutes.home],
      backgroundColor: Colors.grey.shade200,
    ),
  ),
);

/// Map tab declaration.
final mapTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.mapTab,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => const TabPage(
      title: 'Map',
      icon: Icons.map,
      backgroundColor: Colors.blue,
    ),
  ),
);

/// Messages tab declaration with nested navigation.
final messagesTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.messagesTab,
  guards: [
    TabInitGuard(
      tabRoute: AppRoutes.messagesTab,
      childRoute: AppRoutes.chatList,
    ),
  ],
  routeBuilder: RouteBuilder.outlet(
    outletBuilder: (context, routeNode, outlet) => outlet,
  ),
  declarations: [
    RouteDeclaration.routeBuilder(
      route: AppRoutes.chatList,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => TabPage(
          title: 'Messages',
          icon: Icons.message,
          nextRoutes: const [AppRoutes.chat],
          backgroundColor: Colors.green.shade700,
        ),
      ),
    ),
    RouteDeclaration.routeBuilder(
      route: AppRoutes.chat,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => const TabPage(
          title: 'Support chat',
          icon: Icons.chat,
          backgroundColor: Colors.green,
        ),
      ),
    ),
  ],
);

/// Profile tab declaration mounted as a nested schema.
final profileTabDeclaration = RouteDeclaration.scheme(
  route: AppRoutes.profileTab,
  schema: ProfileNavigationSchema(),
  // You could add an InheritedWidget here to pass profile data.
  outletBuilder: (context, routeNode, outlet) => outlet,
);

/// Settings tab declaration.
final settingsTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.settingsTab,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => const TabPage(
      title: 'Settings',
      icon: Icons.settings,
      backgroundColor: Colors.purple,
    ),
  ),
);

/// Home declaration with tabs (IndexedDeclaration).
final homeDeclaration = RouteDeclaration.indexedStack(
  route: AppRoutes.home,
  routeBuilder: RouteIndexedStackBuilder(
    indexedBuilder: (context, routeNode, indexedStack, controller) {
      final activeRoute = controller.activeRoute ?? AppRoutes.mapTab;
      final tabs = [
        AppRoutes.mapTab,
        AppRoutes.messagesTab,
        AppRoutes.profileTab,
        AppRoutes.settingsTab,
      ];
      final currentIndex = tabs.indexOf(activeRoute);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Driver app'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                final navigator = YxNavigation.navigatorOf(context);
                // Go back to authentication.
                navigator.popUntil((node) => node.route == AppRoutes.root);
                navigator.push(AppRoutes.authentication);
              },
              tooltip: 'Sign out',
            ),
          ],
        ),
        body: indexedStack,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            controller.setActiveRoute(tabs[index]);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
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
  declarations: [
    mapTabDeclaration,
    messagesTabDeclaration,
    profileTabDeclaration, // Nested schema lives inside a tab.
    settingsTabDeclaration,
  ],
);

/// Root declaration with an outlet.
final rootDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.root,
  routeBuilder: RouteBuilder.outlet(
    outletBuilder: (context, routeNode, outlet) => outlet,
  ),
  declarations: [
    authDeclaration,
    homeDeclaration,
  ],
);

/// App navigation schema.
base class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema();

  @override
  List<RouteDeclaration> get declarations => [
        rootDeclaration,
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) => node.copyWith(
        children: [
          AppRoutes.root.toNode(
            children: [
              // Start with authentication.
              AppRoutes.authentication.toNode(),
            ],
          ),
        ],
      );
}

class DriverAppWithTabsApp extends StatefulWidget {
  const DriverAppWithTabsApp({super.key});

  @override
  State<DriverAppWithTabsApp> createState() => _DriverAppWithTabsAppState();
}

class _DriverAppWithTabsAppState extends State<DriverAppWithTabsApp> {
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
        title: 'Example 6: Driver app with TabBar and Profile',
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
