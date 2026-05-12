import 'package:flutter/material.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'demo_configurations.dart';
import 'host_app_schema.dart';

void main() {
  runApp(const NavigationConfigProviderDemoApp());
}

/// Demo app for NavigationConfigProvider.
class NavigationConfigProviderDemoApp extends StatefulWidget {
  const NavigationConfigProviderDemoApp({super.key});

  @override
  State<NavigationConfigProviderDemoApp> createState() =>
      _NavigationConfigProviderDemoAppState();
}

class _NavigationConfigProviderDemoAppState
    extends State<NavigationConfigProviderDemoApp> {
  late YxRouterConfig _config;
  final demoModeNotifier = ValueNotifier<DemoMode>(DemoMode.standard);

  @override
  void initState() {
    super.initState();
    _buildConfig();
  }

  void _buildConfig() {
    // Build the schema without binding it to demoModeNotifier.
    final hostSchema = HostAppSchema();
    _config = hostSchema.build(
      debugConfiguration: NavigationDebugConfiguration(
        defaultDisplayType: DebugPanelDisplayType.splitTrailing,
        debugPanelModeNotifier: DebugPanelModeNotifier(enableDebugPanel: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DemoModeProvider(
        demoModeNotifier: demoModeNotifier,
        child: ValueListenableBuilder<DemoMode>(
          valueListenable: demoModeNotifier,
          // Wrap MaterialApp in NavigationConfigProvider using the current defaults.
          builder: (context, demoMode, child) => NavigationConfigProvider(
            defaults: DemoConfigurations.getConfiguration(demoMode),
            child: MaterialApp.router(
              title: 'NavigationConfigProvider Demo',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              debugShowCheckedModeBanner: false,
              routerConfig: _config,
            ),
          ),
        ),
      );

  @override
  void dispose() {
    demoModeNotifier.dispose();
    _config.dispose();
    super.dispose();
  }
}

/// Provider that exposes the current demo-mode notifier.
class DemoModeProvider extends InheritedWidget {
  final ValueNotifier<DemoMode> demoModeNotifier;

  const DemoModeProvider({
    required this.demoModeNotifier,
    required super.child,
    super.key,
  });

  static ValueNotifier<DemoMode> of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<DemoModeProvider>();
    return provider!.demoModeNotifier;
  }

  @override
  bool updateShouldNotify(DemoModeProvider oldWidget) =>
      demoModeNotifier != oldWidget.demoModeNotifier;
}
