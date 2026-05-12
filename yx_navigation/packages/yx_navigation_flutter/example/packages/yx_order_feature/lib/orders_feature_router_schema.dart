import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'src/leaf_page.dart';
import 'src/order_routes.dart';

export 'src/order_routes.dart';

base class OrdersFeatureRouterSchema extends RouterSchema {
  OrdersFeatureRouterSchema();

  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) {
    node.setChildren(
      [
        OrderRoutes.home.toNode(
          children: [
            OrderRoutes.salary.toNode(
              children: [
                OrderRoutes.salaryHistory.toNode(),
              ],
            ),
            OrderRoutes.online.toNode(),
            OrderRoutes.order.toNode(),
            OrderRoutes.history.toNode(),
          ],
        ),
      ],
    );
    return node;
  }

  @override
  List<RouteDeclaration> get declarations => [
        RouteBuilderDeclaration(
          route: OrderRoutes.home,
          routeBuilder: RouteBuilder.outlet(
            outletBuilder: (_, __, outlet) => outlet,
          ),
          declarations: [
            RouteBuilderDeclaration(
              route: OrderRoutes.online,
              routeBuilder: RouteBuilder.widget(
                builder: (context, state) =>
                    const OrderExampleLeafPage(title: 'Order / Online'),
              ),
            ),
            RouteBuilderDeclaration(
              route: OrderRoutes.history,
              routeBuilder: RouteBuilder.widget(
                builder: (context, state) =>
                    const OrderExampleLeafPage(title: 'Order / History'),
              ),
            ),
            RouteBuilderDeclaration(
              route: OrderRoutes.order,
              routeBuilder: RouteBuilder.widget(
                builder: (context, state) =>
                    const OrderExampleLeafPage(title: 'Order / Current Order'),
              ),
            ),
            RouteBuilderDeclaration(
              route: OrderRoutes.salary,
              routeBuilder: RouteBuilder.widget(
                builder: (context, state) =>
                    const OrderExampleLeafPage(title: 'Order / Salary'),
              ),
              declarations: [
                RouteBuilderDeclaration(
                  route: OrderRoutes.salaryHistory,
                  routeBuilder: RouteBuilder.widget(
                    builder: (context, state) => const OrderExampleLeafPage(
                      title: 'Order / Salary / Payments',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ];
}
