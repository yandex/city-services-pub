import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'app_routes.dart';
import 'main.dart';
import 'nested/profile_navigation_schema.dart';

final class AppNavigationSchema extends RouterSchema {
  AppNavigationSchema({
    Iterable<DeeplinkHandler> deeplinkHandlers = const [],
    DeeplinkHandlerStrategy deeplinkStrategy =
        const DeeplinkHandlerStrategy.fifo(),
    DeeplinkHandlerStrategy profileStrategy =
        const DeeplinkHandlerStrategy.fifo(),
  })  : _deeplinkHandlers = deeplinkHandlers,
        _deeplinkStrategy = deeplinkStrategy,
        _profileStrategy = profileStrategy;

  final Iterable<DeeplinkHandler> _deeplinkHandlers;
  final DeeplinkHandlerStrategy _deeplinkStrategy;
  final DeeplinkHandlerStrategy _profileStrategy;

  @override
  Iterable<DeeplinkHandler> get deeplinkHandlers => _deeplinkHandlers;

  @override
  DeeplinkHandlerStrategy get deeplinkStrategy => _deeplinkStrategy;

  @override
  Iterable<RouteDeclaration> get declarations => [
        RouteDeclaration.routeBuilder(
          route: AppRoutes.home,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) => const HomePage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: AppRoutes.orderDetails,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) {
              final orderId = node.arguments['orderId'] ?? 'Unknown';
              return OrderDetailsPage(orderId: orderId);
            },
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: AppRoutes.orderDetailsV2,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) {
              final orderId = node.arguments['orderId'] ?? 'Unknown';
              return OrderDetailsV2Page(orderId: orderId);
            },
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: AppRoutes.ordersList,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) => const OrdersListPage(),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: AppRoutes.promo,
          routeBuilder: RouteBuilder.widget(
            builder: (context, node) {
              final code = node.arguments['code'] ?? 'UNKNOWN';
              return PromoPage(code: code);
            },
          ),
        ),
        // Nested schema with its own deeplink handlers.
        // ProfileNavigationSchema owns its handlers and
        // their composition strategy.
        RouteDeclaration.scheme(
          route: AppRoutes.profile,
          schema: ProfileNavigationSchema(
            deeplinkStrategy: _profileStrategy,
          ),
        ),
      ];

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..add(RouteNode.fromRoute(route: AppRoutes.home));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = StrategyScope.maybeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Composite Deeplinks')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (scope != null) ...[
            _StrategyIndicator(scope: scope),
            const SizedBox(height: 16),
            _PromoToggleButton(scope: scope),
            const SizedBox(height: 24),
          ],
          const Text(
            'Test Deeplinks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Try /order/123 to see which handler wins based on strategy',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _DeeplinkButton(label: '/track', uri: '/track?event=click'),
              _DeeplinkButton(label: '/order/123', uri: '/order/123'),
              _DeeplinkButton(label: '/orders', uri: '/orders'),
              _DeeplinkButton(label: '/promo', uri: '/promo?code=SAVE20'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Nested Schema Deeplinks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Handled by ProfileDeeplinkHandler from nested schema',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _DeeplinkButton(label: '/profile', uri: '/profile'),
              _DeeplinkButton(
                label: '/profile/settings',
                uri: '/profile/settings',
              ),
              _DeeplinkButton(
                label: '/profile/documents',
                uri: '/profile/documents',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StrategyIndicator extends StatelessWidget {
  final StrategyScope scope;

  const _StrategyIndicator({required this.scope});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _StrategyRow(
            label: 'Root strategy',
            strategyName: scope.strategyName,
            isLifo: scope.isLifo,
            description: scope.isLifo
                ? '/order/* → OrderV2Handler (green)'
                : '/order/* → OrderHandler (blue)',
            hint: 'kUseLifoStrategy',
          ),
          const SizedBox(height: 8),
          _StrategyRow(
            label: 'Profile strategy',
            strategyName: scope.profileStrategyName,
            isLifo: scope.isLifoProfile,
            description: scope.isLifoProfile
                ? '/profile/settings → SettingsV2Handler (green)'
                : '/profile/settings → SettingsV1Handler (blue)',
            hint: 'kUseLifoProfileStrategy',
          ),
        ],
      );
}

class _StrategyRow extends StatelessWidget {
  final String label;
  final String strategyName;
  final bool isLifo;
  final String description;
  final String hint;

  const _StrategyRow({
    required this.label,
    required this.strategyName,
    required this.isLifo,
    required this.description,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLifo ? Colors.green : Colors.blue;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isLifo ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label: $strategyName',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                Text(
                  'Change $hint in main.dart',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoToggleButton extends StatelessWidget {
  final StrategyScope scope;

  const _PromoToggleButton({required this.scope});

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: scope.onTogglePromo,
        icon: Icon(scope.isPromoAttached ? Icons.remove : Icons.add),
        label: Text(
          scope.isPromoAttached
              ? 'Detach Promo Handler'
              : 'Attach Promo Handler',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              scope.isPromoAttached ? Colors.orange : Colors.purple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
        ),
      );
}

class _DeeplinkButton extends StatelessWidget {
  final String label;
  final String uri;

  const _DeeplinkButton({required this.label, required this.uri});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: () {
          final router = Router.of(context);
          final provider = router.routeInformationProvider;
          if (provider is YxRouteInformationProvider) {
            provider
                .didPushRouteInformation(RouteInformation(uri: Uri.parse(uri)));
          }
        },
        child: Text(label),
      );
}

/// Order details page V1 - shown when FIFO strategy is used.
///
/// This page has a blue theme to clearly demonstrate
/// which handler processed the deeplink.
class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Order #$orderId'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'Order ID: $orderId',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'V1 Handler (FIFO wins)',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'This page is shown when OrderV1DeeplinkHandler wins',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            final orderId = '${1000 + index}';
            return ListTile(
              leading: const Icon(Icons.receipt),
              title: Text('Order #$orderId'),
              subtitle: Text(
                'Opens via deeplink /order/$orderId',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              onTap: () {
                // Navigate via deeplink to demonstrate strategy
                final router = Router.of(context);
                final provider = router.routeInformationProvider;
                if (provider is YxRouteInformationProvider) {
                  provider.didPushRouteInformation(
                    RouteInformation(uri: Uri.parse('/order/$orderId')),
                  );
                }
              },
            );
          },
        ),
      );
}

class PromoPage extends StatelessWidget {
  final String code;

  const PromoPage({super.key, required this.code});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Promo'),
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.card_giftcard, size: 64, color: Colors.pink),
              const SizedBox(height: 16),
              Text(
                'Promo Code Applied!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                code,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                'This page is from dynamically attached module',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
}

/// Order details page V2 - shown when LIFO strategy is used.
///
/// This page has a different visual style (green theme) to clearly
/// demonstrate which handler processed the deeplink.
class OrderDetailsV2Page extends StatelessWidget {
  final String orderId;

  const OrderDetailsV2Page({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Order #$orderId (V2)'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Order ID: $orderId',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'V2 Handler (LIFO wins)',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'This page is shown when OrderV2DeeplinkHandler wins',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
