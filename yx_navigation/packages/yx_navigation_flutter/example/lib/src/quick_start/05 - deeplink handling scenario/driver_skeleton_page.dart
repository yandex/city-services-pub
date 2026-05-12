import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// Base page with skeleton UI for deeplink handling demonstration
class DriverSkeletonPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Color? color;

  const DriverSkeletonPage({
    required this.title,
    required this.icon,
    this.subtitle,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeNode = RouteNodeProvider.routeNodeOf(context);
    final arguments = routeNode.arguments;
    final navigator = YxNavigation.navigatorOf(context);
    final canPop = navigator.canPop();
    final effectiveColor = color ?? Colors.deepPurple;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        centerTitle: false,
        backgroundColor: effectiveColor,
        foregroundColor: Colors.white,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: navigator.pop,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: effectiveColor),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (arguments.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildArgumentsCard(context, arguments),
            ],
            const SizedBox(height: 32),
            _buildRouteInfo(context, routeNode),
            const SizedBox(height: 24),
            _buildDeeplinkTestButtons(context),
            const SizedBox(height: 24),
            _buildDeeplinkInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildArgumentsCard(
    BuildContext context,
    Map<String, String> arguments,
  ) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Arguments from deeplink:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...arguments.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildRouteInfo(BuildContext context, RouteNode routeNode) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Route ID: ${routeNode.route.id}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
        ),
      );

  Widget _buildDeeplinkTestButtons(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Test Deeplinks (Hot)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DeeplinkButton(
                  label: '/alert (handled)',
                  uri: Uri.parse('/alert?msg=Hot%20deeplink%20test!'),
                  color: Colors.green,
                ),
                _DeeplinkButton(
                  label: '/settings (push)',
                  uri: Uri.parse('/settings'),
                  color: Colors.purple,
                ),
                _DeeplinkButton(
                  label: '/order_details (navigate)',
                  uri: Uri.parse('/order_details?id=999'),
                  color: Colors.orange,
                ),
                _DeeplinkButton(
                  label: '/crash (error)',
                  uri: Uri.parse('/crash'),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildDeeplinkInfo(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  'DeeplinkHandler Demo',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• /order_details?id=123 — navigate to order details\n'
              '• /settings — push settings on top of current screen\n'
              '• /alert?msg=Hello — show SnackBar without navigation\n'
              '• /crash — demonstrate error handling',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
}

/// Button for testing hot deeplinks
class _DeeplinkButton extends StatelessWidget {
  final String label;
  final Uri uri;
  final Color color;

  const _DeeplinkButton({
    required this.label,
    required this.uri,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: () => _triggerDeeplink(context),
        icon: const Icon(Icons.link, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );

  void _triggerDeeplink(BuildContext context) {
    // Simulate an incoming deeplink via YxRouteInformationProvider
    final router = Router.of(context);
    final provider = router.routeInformationProvider;

    if (provider is YxRouteInformationProvider) {
      provider.didPushRouteInformation(RouteInformation(uri: uri));
    }
  }
}
