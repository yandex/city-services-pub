// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'common/tab_page.dart';

/// Example 4: Tabs with RouteDeclaration.routeBuilder + RouteBuilder.indexed.
///
/// Shows an alternative way to build tabs using a regular
/// RouteDeclaration.routeBuilder with RouteBuilder.indexed.
///
/// Navigation structure:
/// ```
/// Home (Builder + IndexedStack)
///   TabBar: Map | Messages | Profile | Settings
///   Tab content (IndexedStack):
///     - Map page
///     - Messages page
///     - Profile page
///     - Settings page
/// ```
///
/// Differences from RouteDeclaration.indexedStack:
/// - No guards are created automatically
/// - Children must be filled in manually inside initialNodeBuilder
/// - More control over the state
/// - A good fit for dynamic tabs
void main() {
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));
  runApp(const TabsBuilderDeclarationApp());
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

/// Home declaration with RouteBuilder.indexed.
///
/// Differences from RouteDeclaration.indexedStack:
/// 1. Uses RouteDeclaration.routeBuilder instead of indexedStack
/// 2. Guards are NOT generated automatically
/// 3. Children MUST be declared manually in initialNodeBuilder
/// 4. The lack of a guard gives you freedom to use dynamic tab-switching
///    logic and to add / remove tabs at runtime.
final homeDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.home,
  routeBuilder: RouteBuilder.indexed(
    indexedBuilder: (context, routeNode, indexedStack, controller) {
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
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Approach comparison'),
                    content: const Text(
                      'RouteDeclaration.routeBuilder + indexed:\n\n'
                      '- More control\n'
                      '- Manual children management\n'
                      '- Fits dynamic tabs\n\n'
                      'RouteDeclaration.indexedStack:\n\n'
                      '- Automatic guards\n'
                      '- Simpler for static tabs\n'
                      '- Less boilerplate',
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
        body: indexedStack,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
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
  // Nested declarations.
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

  // Important: children must be added manually.
  // RouteDeclaration.routeBuilder does not create guards, so
  // every tab has to be listed in children explicitly.
  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) => node.copyWith(
        children: [
          AppRoutes.home.toNode(
            children: [
              // Add every tab explicitly.
              AppRoutes.map.toNode(),
              AppRoutes.messages.toNode(),
              AppRoutes.profile.toNode(),
              AppRoutes.settings.toNode(),
            ],
          ),
        ],
      );
}

class TabsBuilderDeclarationApp extends StatefulWidget {
  const TabsBuilderDeclarationApp({super.key});

  @override
  State<TabsBuilderDeclarationApp> createState() =>
      _TabsBuilderDeclarationAppState();
}

class _TabsBuilderDeclarationAppState extends State<TabsBuilderDeclarationApp> {
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
        title: 'Example 4: Tabs with the builder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
}
