import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'app_deeplink_handler.dart';
import 'app_deeplink_handler_observer.dart';
import 'driver_navigation_schema.dart';

/// Entry point for deeplink handling demonstration
///
/// Available deeplinks for testing (in browser address bar):
/// - `/order_details?id=123` — navigate to order details screen with parameter
/// - `/settings` — push settings screen on top of current
/// - `/alert?msg=Hello` — show SnackBar without navigation
/// - `/crash` — demonstrate error handling
void main() {
  // Set URL strategy for web (removes # from URL)
  setUrlStrategy(PathUrlStrategy(BrowserPlatformLocation(), true));

  runApp(const DeeplinkDemoApp());
}

/// Demo app for deeplink handling
class DeeplinkDemoApp extends StatefulWidget {
  const DeeplinkDemoApp({super.key});

  @override
  State<DeeplinkDemoApp> createState() => _DeeplinkDemoAppState();
}

class _DeeplinkDemoAppState extends State<DeeplinkDemoApp> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late YxRouterConfig _config;
  late DebugPanelModeNotifier _debugPanelModeNotifier;

  @override
  void initState() {
    super.initState();

    _debugPanelModeNotifier = DebugPanelModeNotifier(enableDebugPanel: true);

    final schema = DriverNavigationSchema(
      deeplinkHandlers: [
        AppDeeplinkHandler(
          scaffoldMessengerKey: _scaffoldMessengerKey,
        ),
      ],
    );
    _config = schema.build(
      debugConfiguration: NavigationDebugConfiguration(
        debugPanelModeNotifier: _debugPanelModeNotifier,
        defaultDisplayType: DebugPanelDisplayType.splitTrailing,
      ),
      routerConfiguration: const RouterConfiguration(
        deeplinkObserver: AppDeeplinkHandlerObserver(),
      ),
      navigatorConfiguration: NavigatorConfiguration(
        navigatorBuilder: (context, outlet) => Column(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple, width: 3),
                ),
                child: outlet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Deeplink Handling Demo',
        scaffoldMessengerKey: _scaffoldMessengerKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: _config,
      );

  @override
  void dispose() {
    _config.dispose();
    super.dispose();
  }
}
