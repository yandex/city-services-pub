// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import '../quick_start/01 - profile - flutter-first-scenario/profile_navigation_schema.dart';
import 'common/simple_page.dart';
import 'common/tab_page.dart';
import 'guards/tab_init_guard.dart';

/// Example 8: Full-scale driver app.
///
/// A comprehensive example that combines every technique from the previous
/// files:
/// - RouteDeclaration.routeBuilder with multiple builders
/// - RouteDeclaration.indexedStack for tabs
/// - RouteDeclaration.scheme for nested features
/// - Guards for auth gating
/// - Business-Logic-First approach
///
/// Navigation structure:
/// ```
/// Root (outlet)
///   Splash (auth check)
///   Authentication (outlet)
///     - Login
///     - Register
///     - Restore password
///   Main (IndexedStack - tabs)
///     Tabs: Map | Messages | Profile | Settings
///     - Map Tab (outlet)
///         - Current Order
///         - Order History
///     - Messages Tab (outlet)
///         - Chat List
///         - Chat Details
///     - Profile Tab (Schema)
///         ProfileNavigationSchema
///     - Settings Tab (outlet)
///         - Main Settings
///         - App Settings
///         - About
/// ```
void main() {
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));
  runApp(const ComplexDriverApp());
}

/// App routes.
abstract class AppRoutes {
  // Root routes
  static const root = YxRoute(id: 'root');
  static const splash = YxRoute(id: 'splash');
  static const auth = YxRoute(id: 'auth');
  static const main = YxRoute(id: 'main');

  // Authentication
  static const login = YxRoute(id: 'login');
  static const register = YxRoute(id: 'register');
  static const restore = YxRoute(id: 'restore');

  // Tabs
  static const mapTab = YxRoute(id: 'map-tab');
  static const messagesTab = YxRoute(id: 'messages-tab');
  static const profileTab = YxRoute(id: 'profile-tab');
  static const settingsTab = YxRoute(id: 'settings-tab');

  // Map Tab
  static const currentOrder = YxRoute(id: 'current-order');
  static const orderHistory = YxRoute(id: 'order-history');

  // Messages Tab
  static const chatList = YxRoute(id: 'chat-list');
  static const chatDetails = YxRoute(id: 'chat-details');

  // Settings Tab
  static const mainSettings = YxRoute(id: 'main-settings');
  static const appSettings = YxRoute(id: 'app-settings');
  static const about = YxRoute(id: 'about');
}

// ============================================================================
// Authentication Flow
// ============================================================================

final splashDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.splash,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Loading...',
      nextRoutes: const [AppRoutes.auth, AppRoutes.main],
      backgroundColor: Colors.blue.shade100,
    ),
  ),
);

final authDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.auth,
  guards: [
    TabInitGuard(
      tabRoute: AppRoutes.auth,
      childRoute: AppRoutes.login,
    ),
  ],
  routeBuilder: RouteBuilder.outlet(
    outletBuilder: (context, routeNode, outlet) => Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: outlet,
    ),
  ),
  declarations: [
    RouteDeclaration.routeBuilder(
      route: AppRoutes.login,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => SimplePage(
          title: 'Sign in',
          nextRoutes: const [
            AppRoutes.register,
            AppRoutes.restore,
            AppRoutes.main,
          ],
          backgroundColor: Colors.white,
        ),
      ),
    ),
    RouteDeclaration.routeBuilder(
      route: AppRoutes.register,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => SimplePage(
          title: 'Register',
          nextRoutes: const [AppRoutes.main],
          backgroundColor: Colors.green.shade50,
        ),
      ),
    ),
    RouteDeclaration.routeBuilder(
      route: AppRoutes.restore,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => SimplePage(
          title: 'Restore password',
          backgroundColor: Colors.orange[50],
        ),
      ),
    ),
  ],
);

// ============================================================================
// Main App with Tabs
// ============================================================================

// Map tab with nested navigation.
final mapTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.mapTab,
  guards: [
    TabInitGuard(
      tabRoute: AppRoutes.mapTab,
      childRoute: AppRoutes.currentOrder,
    ),
  ],
  routeBuilder: RouteBuilder.outlet(
    outletBuilder: (context, routeNode, outlet) => outlet,
  ),
  declarations: [
    RouteDeclaration.routeBuilder(
      route: AppRoutes.currentOrder,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => TabPage(
          title: 'Current order',
          icon: Icons.delivery_dining,
          nextRoutes: const [AppRoutes.orderHistory],
          backgroundColor: Colors.blue.shade600,
        ),
      ),
    ),
    RouteDeclaration.routeBuilder(
      route: AppRoutes.orderHistory,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => const TabPage(
          title: 'Order history',
          icon: Icons.history,
          backgroundColor: Colors.blue,
        ),
      ),
    ),
  ],
);

// Messages tab with nested navigation.
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
          title: 'Chats',
          icon: Icons.forum,
          nextRoutes: const [AppRoutes.chatDetails],
          backgroundColor: Colors.green.shade700,
        ),
      ),
    ),
    RouteDeclaration.routeBuilder(
      route: AppRoutes.chatDetails,
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

// Profile tab mounted as a nested schema.
final profileTabDeclaration = RouteDeclaration.scheme(
  route: AppRoutes.profileTab,
  schema: ProfileNavigationSchema(),
);

// Settings tab with nested navigation.
final settingsTabDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.settingsTab,
  guards: [
    TabInitGuard(
      tabRoute: AppRoutes.settingsTab,
      childRoute: AppRoutes.mainSettings,
    ),
  ],
  routeBuilder: RouteBuilder.outlet(
    outletBuilder: (context, routeNode, outlet) => outlet,
  ),
  declarations: [
    RouteDeclaration.routeBuilder(
      route: AppRoutes.mainSettings,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => TabPage(
          title: 'Settings',
          icon: Icons.settings,
          nextRoutes: const [AppRoutes.appSettings, AppRoutes.about],
          backgroundColor: Colors.purple.shade700,
        ),
      ),
    ),
    RouteDeclaration.routeBuilder(
      route: AppRoutes.appSettings,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => const TabPage(
          title: 'App settings',
          icon: Icons.tune,
          backgroundColor: Colors.purple,
        ),
      ),
    ),
    RouteDeclaration.routeBuilder(
      route: AppRoutes.about,
      routeBuilder: RouteBuilder.widget(
        builder: (context, routeNode) => const TabPage(
          title: 'About',
          icon: Icons.info,
          backgroundColor: Colors.indigo,
        ),
      ),
    ),
  ],
);

// Main with tabs.
final mainDeclaration = RouteDeclaration.indexedStack(
  route: AppRoutes.main,
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
                navigator.push(AppRoutes.auth);
              },
              tooltip: 'Sign out',
            ),
          ],
        ),
        body: indexedStack,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => controller.setActiveRoute(tabs[index]),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
    profileTabDeclaration,
    settingsTabDeclaration,
  ],
);

// Root outlet.
final rootDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.root,
  routeBuilder: RouteBuilder.outlet(
    outletBuilder: (context, routeNode, outlet) => outlet,
  ),
  declarations: [
    splashDeclaration,
    authDeclaration,
    mainDeclaration,
  ],
);

/// Navigation schema.
base class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema();

  @override
  List<RouteDeclaration> get declarations => [rootDeclaration];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) => node.copyWith(
        children: [
          AppRoutes.root.toNode(
            children: [
              AppRoutes.splash.toNode(),
            ],
          ),
        ],
      );
}

class ComplexDriverApp extends StatefulWidget {
  const ComplexDriverApp({super.key});

  @override
  State<ComplexDriverApp> createState() => _ComplexDriverAppState();
}

class _ComplexDriverAppState extends State<ComplexDriverApp> {
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
        title: 'Example 8: Full-scale app',
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
