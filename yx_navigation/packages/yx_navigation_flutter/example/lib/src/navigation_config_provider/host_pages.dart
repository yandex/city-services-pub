import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'demo_configurations.dart';
import 'host_routes.dart';
import 'main.dart';

/// Base page for the host application.
class HostBasePage extends StatelessWidget {
  final String title;
  final List<YxRoute> availableRoutes;
  final String description;

  const HostBasePage({
    required this.title,
    required this.availableRoutes,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);
    final canPop = routeNavigator.canPop();
    final demoModeNotifier = DemoModeProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: routeNavigator.pop,
              )
            : null,
        actions: [
          // Demo-mode switcher.
          PopupMenuButton<DemoMode>(
            icon: const Icon(Icons.settings),
            tooltip: 'Profile demo mode',
            onSelected: (mode) => demoModeNotifier.value = mode,
            itemBuilder: (context) => DemoMode.values
                .map(
                  (mode) => PopupMenuItem<DemoMode>(
                    value: mode,
                    child: ValueListenableBuilder<DemoMode>(
                      valueListenable: demoModeNotifier,
                      builder: (context, currentMode, child) {
                        final isSelected = currentMode == mode;
                        return ListTile(
                          leading: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.blue : null,
                          ),
                          title: Text(
                            mode.title,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : null,
                            ),
                          ),
                          subtitle: Text(
                            mode.description,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Host application',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Uses the default Material navigation configuration',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Current demo-mode info.
            ValueListenableBuilder<DemoMode>(
              valueListenable: demoModeNotifier,
              builder: (context, demoMode, child) => Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Profile mode: ${demoMode.title}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DemoConfigurations.getChangesDescription(demoMode),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use the settings icon in the AppBar to switch modes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (availableRoutes.isNotEmpty) ...[
              Text(
                'Available destinations:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ...availableRoutes.map(
                (route) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => routeNavigator.push(route),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_getRouteTitle(route)),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Widget demonstrations.
            Text(
              'Widget showcase:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'These buttons show the overridden not-found and empty widgets',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange[600],
                  ),
            ),
            const SizedBox(height: 16),
            // Button to demonstrate the Not Found widget.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to a non-existent route.
                  routeNavigator.push(const YxRoute(id: 'non-existent-route'));
                },
                icon: const Icon(Icons.error_outline),
                label: const Text('Navigate to a non-existent route'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Button to demonstrate the Empty widget.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  routeNavigator.push(HostRoutes.demoEmpty);
                },
                icon: const Icon(Icons.inbox_outlined),
                label: const Text('Show the empty widget'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRouteTitle(YxRoute route) {
    switch (route.id) {
      case 'host-home':
        return 'Home';
      case 'host-settings':
        return 'Settings';
      case 'host-about':
        return 'About';
      case 'host-profile':
        return 'Driver profile (nested schema)';
      default:
        return route.id;
    }
  }
}

/// Host application home page.
class HostHomePage extends StatelessWidget {
  const HostHomePage({super.key});

  @override
  Widget build(BuildContext context) => const HostBasePage(
        title: 'Home',
        description: 'Home page of the host application. '
            'From here you can navigate to other sections of the app, '
            'including the nested driver-profile schema.',
        availableRoutes: [
          HostRoutes.settings,
          HostRoutes.about,
          HostRoutes.profile,
        ],
      );
}

/// Host application settings page.
class HostSettingsPage extends StatelessWidget {
  const HostSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const HostBasePage(
        title: 'Settings',
        description: 'Settings page for the host application. '
            'Adjust various app preferences here.',
        availableRoutes: [
          HostRoutes.about,
          HostRoutes.profile,
        ],
      );
}

/// "About" page.
class HostAboutPage extends StatelessWidget {
  const HostAboutPage({super.key});

  @override
  Widget build(BuildContext context) => const HostBasePage(
        title: 'About',
        description: 'Information about the host application. '
            'This demo shows how to override navigation configuration '
            'via NavigationConfigProvider.',
        availableRoutes: [
          HostRoutes.profile,
        ],
      );
}
