import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// Page rendered inside a tab.
///
/// Used in the TabBar / BottomNavigationBar examples. May host nested
/// navigation.
class TabPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<YxRoute> nextRoutes;
  final Color? backgroundColor;

  const TabPage({
    required this.title,
    required this.icon,
    this.nextRoutes = const [],
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (nextRoutes.isNotEmpty) ...[
              Text(
                'Navigation inside the tab:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ...nextRoutes.map(
                (route) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    onPressed: () => routeNavigator.push(route),
                    child: Text('Open ${route.id}'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
