import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// Simple page used to demonstrate navigation.
///
/// Used across examples to showcase basic concepts. Shows a title and a
/// list of buttons that push the next routes.
class SimplePage extends StatelessWidget {
  final String title;
  final List<YxRoute> nextRoutes;
  final Map<YxRoute, String>? routeDescriptions;
  final Color? backgroundColor;

  const SimplePage({
    required this.title,
    this.nextRoutes = const [],
    this.routeDescriptions,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);
    final canPop = routeNavigator.canPop();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title),
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: routeNavigator.pop,
                tooltip: 'Back',
              )
            : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (nextRoutes.isNotEmpty) ...[
              Text(
                'Available destinations:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ...nextRoutes.map((route) {
                final description = routeDescriptions?[route];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    onPressed: () => routeNavigator.push(route),
                    child: description != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Open ${route.id}'),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Text('Open ${route.id}'),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
