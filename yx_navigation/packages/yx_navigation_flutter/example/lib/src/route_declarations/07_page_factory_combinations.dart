// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'common/simple_page.dart';

/// Example 7: Page factory combinations.
///
/// Shows how to use the built-in PagesFactory to configure page
/// transitions and behavior.
///
/// Navigation structure:
/// ```
/// Home (MaterialPage - default transition)
///   -> Settings (CupertinoPage - iOS style)
///   -> Dialog (MaterialPage - fullscreen dialog)
///   -> DialogRoute (custom DialogRoute - modal dialog)
///   -> Fullscreen (custom fade + scale transition)
/// ```
///
/// Key concepts:
/// - PagesFactory.material() - default Material transitions
/// - PagesFactory.cupertino() - iOS-style transitions
/// - PagesFactory.custom() - custom transitions
/// - PagesFactory.modalBottomSheet() - for bottom sheets
/// - DialogRoute via a custom Page for modal dialogs
/// - Reusing builders with different factories
void main() {
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));
  runApp(const PageFactoryApp());
}

/// App routes.
abstract class AppRoutes {
  static const home = YxRoute(id: 'home');
  static const settings = YxRoute(id: 'settings');
  static const dialog = YxRoute(id: 'dialog');
  static const fullscreen = YxRoute(id: 'fullscreen');
  static const dialogRoute = YxRoute(id: 'dialog-route');
}

/// Custom Page for DialogRoute.
///
/// Shows a modal dialog on top of the current content.
class DialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final Widget child;

  const DialogPage({
    required this.child,
    this.anchorPoint,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    final capturedThemes = themes ??
        InheritedTheme.capture(
          from: context,
          to: Navigator.of(context, rootNavigator: true).context,
        );

    return DialogRoute<T>(
      context: context,
      builder: (context) => child,
      barrierColor: barrierColor,
      themes: capturedThemes,
      settings: this,
      anchorPoint: anchorPoint,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
    );
  }
}

/// Custom page with a fade + scale animation.
class _CustomTransitionPage extends Page {
  final Widget child;

  const _CustomTransitionPage({
    required this.child,
    required super.key,
    required super.name,
  });

  @override
  Route createRoute(BuildContext context) => PageRouteBuilder(
        settings: this,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        // Combine fade and scale animations.
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      );
}

/// Home declaration (default MaterialPage).
final homeDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.home,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Page Factory Demo',
      nextRoutes: const [
        AppRoutes.settings,
        AppRoutes.dialog,
        AppRoutes.dialogRoute,
        AppRoutes.fullscreen,
      ],
      routeDescriptions: {
        AppRoutes.settings: 'iOS-style transition',
        AppRoutes.dialog: 'Fullscreen dialog',
        AppRoutes.dialogRoute: 'Modal dialog',
        AppRoutes.fullscreen: 'Fade + scale animation',
      },
      backgroundColor: Colors.blue.shade50,
    ),
    // PagesFactory.material() is used by default.
  ),
);

/// Settings declaration (Cupertino style).
final settingsDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.settings,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Settings\n(iOS-style transition)',
      backgroundColor: Colors.orange.shade50,
    ),
    // Use the built-in Cupertino factory.
    pageFactory: const PagesFactory.cupertino(),
  ),
);

/// Dialog declaration (fullscreen dialog).
final dialogDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.dialog,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Dialog\n(Fullscreen dialog)',
      backgroundColor: Colors.purple.shade50,
    ),
    // Use the built-in Material factory with fullscreenDialog.
    pageFactory: const PagesFactory.material(
      fullscreenDialog: true,
    ),
  ),
);

/// DialogRoute declaration (modal dialog via DialogRoute).
final dialogRouteDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.dialogRoute,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Modal dialog',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A real DialogRoute shown over the content',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                YxNavigation.navigatorOf(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    ),
    // Custom factory that creates a DialogRoute.
    pageFactory: PagesFactory.custom(
      builder: (context, routeNode, key, child) => DialogPage(
        key: key,
        name: routeNode.route.id,
        child: child,
        barrierDismissible: true,
        barrierColor: Colors.black54,
      ),
    ),
  ),
);

/// Fullscreen declaration (custom transition).
final fullscreenDeclaration = RouteDeclaration.routeBuilder(
  route: AppRoutes.fullscreen,
  routeBuilder: RouteBuilder.widget(
    builder: (context, routeNode) => SimplePage(
      title: 'Fullscreen\n(Custom Fade + Scale)',
      backgroundColor: Colors.green.shade50,
    ),
    // Use the built-in custom factory.
    pageFactory: PagesFactory.custom(
      builder: (context, routeNode, key, child) => _CustomTransitionPage(
        key: key,
        name: routeNode.route.id,
        child: child,
      ),
    ),
  ),
);

/// App navigation schema.
base class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema();

  @override
  List<RouteDeclaration> get declarations => [
        homeDeclaration,
        settingsDeclaration,
        dialogDeclaration,
        dialogRouteDeclaration,
        fullscreenDeclaration,
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([AppRoutes.home.toNode()]);
}

class PageFactoryApp extends StatefulWidget {
  const PageFactoryApp({super.key});

  @override
  State<PageFactoryApp> createState() => _PageFactoryAppState();
}

class _PageFactoryAppState extends State<PageFactoryApp> {
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
        title: 'Example 7: Page Factory',
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
