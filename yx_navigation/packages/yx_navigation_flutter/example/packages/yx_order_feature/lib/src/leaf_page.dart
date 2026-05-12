import 'package:flutter/material.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

import 'order_routes.dart';

class OrderExampleLeafPage extends StatelessWidget {
  final String title;

  const OrderExampleLeafPage({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final routeNavigator = YxNavigation.navigatorOf(context);
    final parentNavigator = YxNavigation.parentNavigatorOf(context);
    final canPop = routeNavigator.canPop();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$title / canPop: $canPop'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: SizedBox(
          height: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Pop by current route navigator',
                iconSize: 22,
                icon: canPop
                    ? const Icon(Icons.arrow_circle_left)
                    : const Icon(Icons.close_rounded),
                onPressed: canPop
                    ? () {
                        routeNavigator.pop();
                      }
                    : null,
              ),
              if (!canPop)
                IconButton(
                  tooltip: 'Pop by parent navigator',
                  iconSize: 22,
                  icon: const Icon(Icons.arrow_circle_left_outlined),
                  onPressed: parentNavigator.pop,
                ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  routeNavigator.push(OrderRoutes.order);
                },
                child: Text('Open Order'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  routeNavigator.push(OrderRoutes.history);
                },
                child: Text('Open History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
