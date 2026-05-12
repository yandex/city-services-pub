import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'host_pages.dart';
import 'host_routes.dart';
import 'profile_feature/profile_schema.dart';

/// Navigation schema for the host application.
class HostAppSchema extends RouterSchema {
  HostAppSchema();

  @override
  List<RouteDeclaration> get declarations => [
        // Core host-app routes.
        RouteDeclaration.routeBuilder(
          route: HostRoutes.home,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const HostHomePage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: HostRoutes.settings,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const HostSettingsPage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: HostRoutes.about,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => const HostAboutPage(),
          ),
        ),

        // Demo route for the empty state.
        // An outlet with no children creates an empty navigator.
        RouteDeclaration.routeBuilder(
          route: HostRoutes.demoEmpty,
          routeBuilder: RouteBuilder.outlet(),
        ),

        // Nested profile schema with overridden defaults.
        _buildProfileSchemaDeclaration(),
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([HostRoutes.home.toNode()]);

  /// Creates the profile schema declaration with overridden widgets.
  RouteDeclaration _buildProfileSchemaDeclaration() => RouteDeclaration.scheme(
        route: HostRoutes.profile,
        schema: ProfileSchema(),
        outletBuilder: (context, state, outlet) => Builder(
          builder: (context) => NavigationConfigProvider(
            defaults:
                NavigationDefaults.resolveNavigationDefaults(context).copyWith(
              widgetBuilder: _ProfileCustomWidgetBuilder(),
            ),
            child: outlet,
          ),
        ),
      );
}

/// Custom widget builder for the driver profile section.
class _ProfileCustomWidgetBuilder extends RouteNodeWidgetBuilder {
  const _ProfileCustomWidgetBuilder();

  @override
  Widget toNotFoundWidget(
    BuildContext context,
    RouteNode routeNode,
  ) =>
      Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(
          title: const Text('Profile - page not found'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Profile section not found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'The requested driver-profile section does not exist.\nThis is a custom not-found widget for the profile.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => YxNavigation.navigatorOf(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget toEmptyWidget(
    BuildContext context,
    RouteNode routeNode,
  ) =>
      Scaffold(
        backgroundColor: Colors.orange[50],
        appBar: AppBar(
          title: const Text('Profile - empty section'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.orange[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Profile section is empty',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'There is nothing to show in this profile section yet.\nThis is a custom empty widget for the profile.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    YxNavigation.parentNavigatorOf(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}
