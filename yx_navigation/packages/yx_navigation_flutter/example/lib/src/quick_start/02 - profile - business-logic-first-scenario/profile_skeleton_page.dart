import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// Base page with a skeleton UI for the driver-profile demo.
class ProfileSkeletonPage extends StatefulWidget {
  const ProfileSkeletonPage({
    required this.title,
    this.nextRoutes = const [],
    super.key,
  });

  final String title;

  final Iterable<YxRoute> nextRoutes;

  @override
  State<ProfileSkeletonPage> createState() => _ProfileSkeletonPageState();
}

class _ProfileSkeletonPageState extends State<ProfileSkeletonPage> {
  Widget _buildSkeletonBody(
    BuildContext context,
    RouteNavigator routeNavigator,
  ) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section heading placeholder
            _buildSkeletonItem(height: 32, width: 200),
            const SizedBox(height: 24),

            // Skeleton cards
            ...List.generate(3, (index) => _buildSkeletonCard()),

            const SizedBox(height: 32),

            // Navigation buttons for the next pages
            if (widget.nextRoutes.isNotEmpty) ...[
              const Text(
                'Available sections:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.nextRoutes.map(
                (route) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => routeNavigator.push(route),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(
                        _getRouteDisplayName(route.id),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildSkeletonCard() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkeletonItem(height: 20, width: 150),
            const SizedBox(height: 12),
            _buildSkeletonItem(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            _buildSkeletonItem(height: 16, width: 250),
            const SizedBox(height: 8),
            _buildSkeletonItem(height: 16, width: 180),
          ],
        ),
      );

  Widget _buildSkeletonItem({required double height, required double width}) =>
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(
            Radius.circular(4),
          ),
        ),
      );

  String _getRouteDisplayName(String routeId) {
    switch (routeId) {
      case 'profile-driver':
        return 'Driver profile';
      case 'profile-trips-history':
        return 'Trips history';
      case 'profile-statistics':
        return 'Statistics';
      case 'profile-settings':
        return 'Settings';
      case 'profile-documents':
        return 'Documents';
      default:
        return routeId;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grab the navigator to drive page transitions.
    final routeNavigator = YxNavigation.navigatorOf(context);
    final canPop = routeNavigator.canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leadingWidth: 100,
        leading: SizedBox(
          height: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Back',
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
      body: _buildSkeletonBody(context, routeNavigator),
    );
  }
}
