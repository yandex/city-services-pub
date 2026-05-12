import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'profile_deeplink_handler.dart';
import 'profile_routes.dart';
import 'profile_settings_v1_deeplink_handler.dart';
import 'profile_settings_v2_deeplink_handler.dart';

/// Nested navigation schema for the profile section.
///
/// The schema owns its deeplink handlers via the [deeplinkHandlers] getter
/// and defines their composition strategy via [deeplinkStrategy].
/// The parent schema connects [ProfileNavigationSchema] through
/// [RouteDeclaration.scheme] — the profile describes its own handlers.
///
/// [ProfileDeeplinkHandler] — root handler, handles only
/// /profile/documents (does not compete with Settings handlers).
///
/// [ProfileSettingsV1DeeplinkHandler] (V1) and [ProfileSettingsV2DeeplinkHandler] (V2)
/// compete for /profile/settings. The winner is determined by strategy:
/// - FIFO: V1 (registered first) → blue page
/// - LIFO: V2 (registered last) → green page
base class ProfileNavigationSchema extends RouterSchema {
  ProfileNavigationSchema({
    DeeplinkHandlerStrategy deeplinkStrategy =
        const DeeplinkHandlerStrategy.fifo(),
  }) : _deeplinkStrategy = deeplinkStrategy;

  final DeeplinkHandlerStrategy _deeplinkStrategy;

  @override
  DeeplinkHandlerStrategy get deeplinkStrategy => _deeplinkStrategy;

  @override
  Iterable<DeeplinkHandler> get deeplinkHandlers => const [
        ProfileDeeplinkHandler(),
        // V1: first registered Settings handler.
        // FIFO → wins (blue page).
        ProfileSettingsV1DeeplinkHandler(),
        // V2: second registered Settings handler.
        // LIFO → wins (green page).
        ProfileSettingsV2DeeplinkHandler(),
      ];

  @override
  List<RouteDeclaration> get declarations => [
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.home,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) => const ProfileHomePage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.settings,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) => ProfileSettingsPage(
              handlerName: node.arguments['handler'] ?? '—',
            ),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: ProfileRoutes.documents,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) => const ProfileDocumentsPage(),
          ),
        ),
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([ProfileRoutes.home.toNode()]);
}

class ProfileHomePage extends StatelessWidget {
  const ProfileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigator = YxNavigation.navigatorOf(context);
    final canPop = navigator.canPop();

    final parentNavigator = YxNavigation.parentNavigatorOf(context);
    final canPopByParent = parentNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: BackButton(
          onPressed: canPop
              ? navigator.pop
              : (canPopByParent ? parentNavigator.pop : null),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64, color: Colors.teal),
            const SizedBox(height: 16),
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Nested Schema',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'This page is from nested ProfileNavigationSchema',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Try deeplinks: /profile/settings, /profile/documents',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSettingsPage extends StatelessWidget {
  final String handlerName;

  const ProfileSettingsPage({super.key, required this.handlerName});

  @override
  Widget build(BuildContext context) {
    final navigator = YxNavigation.navigatorOf(context);
    final canPop = navigator.canPop();

    final parentNavigator = YxNavigation.parentNavigatorOf(context);
    final canPopByParent = parentNavigator.canPop();

    final isV2 = handlerName.contains('V2');
    final isV1 = handlerName.contains('V1');
    final handlerColor =
        isV2 ? Colors.green : (isV1 ? Colors.blue : Colors.teal);

    final strategyLabel = isV2
        ? 'LIFO wins: V2 handler (last registered)'
        : (isV1
            ? 'FIFO wins: V1 handler (first registered)'
            : 'Generic handler (no Settings competition)');

    final strategyDescription = isV2
        ? 'ProfileNavigationSchema.strategy = LIFO\n'
            'Last registered handler called first →\n'
            'ProfileSettingsV2Handler wins'
        : (isV1
            ? 'ProfileNavigationSchema.strategy = FIFO\n'
                'First registered handler called first →\n'
                'ProfileSettingsV1Handler wins'
            : 'ProfileDeeplinkHandler handles /profile/documents\n'
                'Settings are handled by V1/V2 handlers');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: handlerColor,
        foregroundColor: Colors.white,
        leading: BackButton(
          onPressed: canPop
              ? navigator.pop
              : (canPopByParent ? parentNavigator.pop : null),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: handlerColor),
            const SizedBox(height: 16),
            Text(
              'Profile Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: handlerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: handlerColor),
              ),
              child: Column(
                children: [
                  Text(
                    strategyLabel,
                    style: TextStyle(
                      color: handlerColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    handlerName,
                    style: TextStyle(color: handlerColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                strategyDescription,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDocumentsPage extends StatelessWidget {
  const ProfileDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigator = YxNavigation.navigatorOf(context);
    final canPop = navigator.canPop();

    final parentNavigator = YxNavigation.parentNavigatorOf(context);
    final canPopByParent = parentNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: BackButton(
          onPressed: canPop
              ? navigator.pop
              : (canPopByParent ? parentNavigator.pop : null),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 64, color: Colors.teal),
            const SizedBox(height: 16),
            Text(
              'Documents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Nested Handler (/profile/documents)',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Opened via ProfileDeeplinkHandler\n(from nested ProfileNavigationSchema)',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
