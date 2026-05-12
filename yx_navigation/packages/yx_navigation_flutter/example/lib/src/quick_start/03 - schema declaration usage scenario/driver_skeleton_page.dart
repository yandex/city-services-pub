import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// Base skeleton page for the driver-app demo.
class DriverSkeletonPage extends StatefulWidget {
  const DriverSkeletonPage({
    required this.title,
    required this.icon,
    this.nextRoutes = const [],
    this.description,
    super.key,
  });

  final String title;
  final IconData icon;
  final Iterable<YxRoute> nextRoutes;

  final String? description;

  @override
  State<DriverSkeletonPage> createState() => _DriverSkeletonPageState();
}

class _DriverSkeletonPageState extends State<DriverSkeletonPage> {
  Widget _buildDriverBody(BuildContext context, RouteNavigator navigator) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page description.
            if (widget.description != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.description!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Navigation cards.
            if (widget.nextRoutes.isNotEmpty) ...[
              const Text(
                'Available sections',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.nextRoutes.map(
                (route) => _buildNavigationCard(
                  context,
                  route,
                  navigator,
                ),
              ),
            ],

            // Demo information.
            const SizedBox(height: 24),
            _buildDemoInfo(context),
          ],
        ),
      );

  Widget _buildNavigationCard(
    BuildContext context,
    YxRoute route,
    RouteNavigator navigator,
  ) {
    final routeInfo = _getRouteInfo(route);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple[100],
          child: Icon(
            routeInfo['icon'] as IconData,
            color: Colors.deepPurple[700],
            size: 20,
          ),
        ),
        title: Text(
          routeInfo['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(routeInfo['subtitle'] as String),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => navigator.push(route),
      ),
    );
  }

  Widget _buildDemoInfo(BuildContext context) => Card(
        color: Colors.amber[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.code, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    'RouteDeclaration.scheme demo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '- This example showcases RouteDeclaration.scheme\n'
                '- The "Profile" route mounts the entire ProfileNavigationSchema\n'
                '- Flutter-first approach with a declarative structure',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );

  Map<String, dynamic> _getRouteInfo(YxRoute route) {
    switch (route.id) {
      case 'login':
        return {
          'title': 'Sign in',
          'subtitle': 'Sign in and configure your account',
          'icon': Icons.login,
        };
      case 'home':
        return {
          'title': 'Home dashboard',
          'subtitle': 'Activity and statistics overview',
          'icon': Icons.home,
        };
      case 'orders':
        return {
          'title': 'Orders',
          'subtitle': 'Available and active trips',
          'icon': Icons.work,
        };
      case 'messages':
        return {
          'title': 'Messages',
          'subtitle': 'Support chat and notifications',
          'icon': Icons.message,
        };
      case 'profile':
        return {
          'title': 'Profile',
          'subtitle': 'Profile, documents, statistics (nested schema)',
          'icon': Icons.person,
        };
      default:
        return {
          'title': route.id,
          'subtitle': 'Demo page',
          'icon': Icons.pages,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);
    final canPop = routeNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.icon, size: 24),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leadingWidth: 100,
        leading: SizedBox(
          height: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: canPop ? 'Back' : 'Exit',
                iconSize: 22,
                icon: canPop
                    ? const Icon(Icons.arrow_back)
                    : const Icon(Icons.close),
                onPressed: canPop ? routeNavigator.pop : null,
              ),
            ],
          ),
        ),
      ),
      body: _buildDriverBody(context, routeNavigator),
    );
  }
}
