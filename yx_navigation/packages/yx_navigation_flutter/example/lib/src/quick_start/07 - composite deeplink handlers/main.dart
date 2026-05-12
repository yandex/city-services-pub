import 'package:flutter/material.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'app_navigation_schema.dart';
import 'handlers/analytics_deeplink_handler.dart';
import 'handlers/order_v1_deeplink_handler.dart';
import 'handlers/order_v2_deeplink_handler.dart';
import 'handlers/profile_tab_deeplink_handler.dart';
import 'handlers/promo_deeplink_handler.dart';

// ignore_for_file: avoid_redundant_argument_values

/// Root schema strategy. Change to test which order handler wins for /order/*:
/// - `false` (FIFO): OrderV1DeeplinkHandler wins → blue page
/// - `true` (LIFO): OrderV2DeeplinkHandler wins → green page
const kUseLifoStrategy = false;

/// ProfileNavigationSchema strategy. Change to test which handler wins for /profile/settings:
/// - `false` (FIFO): ProfileSettingsV1Handler (registered first) wins → blue page
/// - `true` (LIFO): ProfileSettingsV2Handler (registered last) wins → green page
///
/// ProfileDeeplinkHandler (root) handles only /profile/documents and is not
/// involved in the /profile/settings competition.
const kUseLifoProfileStrategy = false;

void main() {
  runApp(const CompositeDeeplinkDemo());
}

class CompositeDeeplinkDemo extends StatefulWidget {
  const CompositeDeeplinkDemo({super.key});

  @override
  State<CompositeDeeplinkDemo> createState() => _CompositeDeeplinkDemoState();
}

class _CompositeDeeplinkDemoState extends State<CompositeDeeplinkDemo> {
  late LateInitDeeplinkHandlerImpl _deeplinkHandler;
  late YxRouterConfig _config;
  late DebugPanelModeNotifier _debugPanelModeNotifier;

  bool _isPromoHandlerAttached = false;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  void _initializeNavigation() {
    _debugPanelModeNotifier = DebugPanelModeNotifier(enableDebugPanel: true);

    const strategy = kUseLifoStrategy
        ? DeeplinkHandlerStrategy.lifo()
        : DeeplinkHandlerStrategy.fifo();

    const profileStrategy = kUseLifoProfileStrategy
        ? DeeplinkHandlerStrategy.lifo()
        : DeeplinkHandlerStrategy.fifo();

    _deeplinkHandler = LateInitDeeplinkHandlerImpl(
      strategy: strategy,
      handlers: const [
        AnalyticsDeeplinkHandler(),
        OrderV1DeeplinkHandler(),
        // OrderV2DeeplinkHandler handles the same /order/* path
        // With FIFO: OrderV1DeeplinkHandler wins (registered first)
        // With LIFO: OrderV2DeeplinkHandler wins (registered last)
        OrderV2DeeplinkHandler(),
        // ProfileTabDeeplinkHandler handles /profile base path
        // Nested paths (/profile/settings, /profile/documents) are handled
        // by ProfileDeeplinkHandler from ProfileNavigationSchema
        ProfileTabDeeplinkHandler(),
      ],
    );

    // Schema owns its deeplink handlers and strategy via getters.
    // profileStrategy is independent of root strategy: each schema
    // applies its own strategy when composing its subtree handlers.
    final schema = AppNavigationSchema(
      deeplinkHandlers: [_deeplinkHandler],
      deeplinkStrategy: strategy,
      profileStrategy: profileStrategy,
    );

    _config = schema.build(
      debugConfiguration: NavigationDebugConfiguration(
        debugPanelModeNotifier: _debugPanelModeNotifier,
        defaultDisplayType: DebugPanelDisplayType.splitTrailing,
      ),
      navigatorConfiguration: NavigatorConfiguration(
        navigatorBuilder: (context, outlet) => StrategyScope(
          isLifo: kUseLifoStrategy,
          isLifoProfile: kUseLifoProfileStrategy,
          isPromoAttached: _isPromoHandlerAttached,
          onTogglePromo: _togglePromoHandler,
          child: outlet,
        ),
      ),
    );
  }

  void _togglePromoHandler() {
    setState(() {
      if (_isPromoHandlerAttached) {
        _deeplinkHandler.detach('promo_feature');
      } else {
        _deeplinkHandler.attach('promo_feature', const PromoDeeplinkHandler());
      }
      _isPromoHandlerAttached = !_isPromoHandlerAttached;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Composite Deeplink Handlers',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
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

/// Provides strategy and promo handler state to the widget tree.
class StrategyScope extends InheritedWidget {
  final bool isLifo;
  final bool isLifoProfile;
  final bool isPromoAttached;
  final VoidCallback onTogglePromo;

  const StrategyScope({
    required this.isLifo,
    required this.isLifoProfile,
    required this.isPromoAttached,
    required this.onTogglePromo,
    required super.child,
    super.key,
  });

  static StrategyScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StrategyScope>();

  String get strategyName => isLifo ? 'LIFO' : 'FIFO';
  String get profileStrategyName => isLifoProfile ? 'LIFO' : 'FIFO';

  @override
  bool updateShouldNotify(StrategyScope oldWidget) =>
      isLifo != oldWidget.isLifo ||
      isLifoProfile != oldWidget.isLifoProfile ||
      isPromoAttached != oldWidget.isPromoAttached;
}
