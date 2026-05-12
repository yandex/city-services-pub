# yx_navigation_flutter

<div align="center">

<img src="https://github.com/yandex/city-services-pub/blob/main/yx_navigation/assets/logos/yx_navigation.webp?raw=true" width="200" alt="The yx_navigation package logo" />

**Flutter integration for yx_navigation — schemas, Router / Navigator 2.0, outlets, compatibility.**

[![Pub Version](https://img.shields.io/pub/v/yx_navigation_flutter)](https://pub.dev/packages/yx_navigation_flutter)

</div>

---

Second-layer API: connects declarative route schemas (`RouterSchema`), `RouteDeclaration`,
`NavigatorOutlet`, and page factories to Flutter’s `Router` stack.
Includes debug tooling and a **compatibility** path for legacy Navigator 1.0 (`push`, dialogs,
bottom sheets) where applicable.

Depends on **[yx_navigation](https://pub.dev/packages/yx_navigation)** for all non-UI navigation logic.

## Install

```yaml
dependencies:
  yx_navigation_flutter: ^1.0.0
```

## Documentation

See the repo **[docs/](https://github.com/yandex/city-services-pub/tree/main/yx_navigation/docs)** directory — especially
[Quick start](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/quick_start.md),
[Route declarations](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/route_declarations.md),
[Guards](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/guards.md), and
[Compatibility architecture](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/compatibility_architecture.md).

Runnable scenarios live under `example/lib/src/quick_start/` in this package.

## How to start

Minimal **Flutter-first** setup: describe routes, declare UI for each route, wrap them in a
**`RouterSchema`**, then pass **`YxRouterConfig`** from **`schema.build()`** to **`MaterialApp.router`**.
Dispose the config when the owning **`State`** is disposed.

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

void main() {
  runApp(const DemoApp());
}

abstract final class Routes {
  static const home = YxRoute(id: 'home');
  static const detail = YxRoute(id: 'detail');
}

final class DemoSchema extends RouterSchema {
  DemoSchema()
      : super(
          initialNodeBuilder: (root) => root
            ..setChildren([
              Routes.home.toNode(),
            ]),
        );

  @override
  List<RouteDeclaration> get declarations => [
        RouteDeclaration.routeBuilder(
          route: Routes.home,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Demo')),
              body: Center(
                child: IconButton(
                  icon: const Icon(Icons.navigate_next),
                  onPressed: () {
                    YxNavigation.navigatorOf(context).push(Routes.detail);
                  },
                ),
              ),
            ),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: Routes.detail,
          routeBuilder: RouteBuilder.widget(
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Detail')),
              body: const Center(child: Text('Detail')),
            ),
          ),
        ),
      ];
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  late final YxRouterConfig _routerConfig;

  @override
  void initState() {
    super.initState();
    _routerConfig = DemoSchema().build();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _routerConfig,
    );
  }

  @override
  void dispose() {
    unawaited(_routerConfig.dispose());
    super.dispose();
  }
}
```

The same **`push`** can be triggered from UI via **`YxNavigation`** (when you prefer not to thread callbacks):

```dart
YxNavigation.navigatorOf(context).push(Routes.detail);
```

Other lookups live on **`YxNavigation`** (mutator, navigation controller, etc.).

### Business Logic First

Own **`RouteNodeStateManager`** outside the widget tree—e.g. from DI or interactors—and pass it when building the router:

```dart
featureSchema.build(
  stateManagerConfiguration: StateManagerConfiguration(
    stateManager: stateManagerFromDependencies,
  ),
);
```

Inject the manager into domain code and navigate from methods that are not widgets:

```dart
final class OrdersInteractor {
  OrdersInteractor({required RouteNodeStateManager navigation});

  final RouteNodeStateManager _navigation;

  void openOrderDetails(String orderId) {
    _navigation.push(
      OrdersRoutes.details,
      arguments: {'id': orderId},
    );
  }
}
```

That keeps **`push`**, **`mutate`**, and **`stream`** usable without **`BuildContext`**. Full walkthrough: [Quick start](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/quick_start.md).

### Nesting a feature schema (`RouteDeclaration.scheme`)

Mount an entire feature **`RouterSchema`** under a single host route so the module stays isolated and reusable:

```dart
RouteDeclaration.scheme(
  route: AppRoutes.profile,
  schema: ProfileNavigationSchema(),
);
```

Declare it next to **`routeBuilder`** entries on the host **`RouterSchema`**. See [Quick start](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/quick_start.md) and [Route declarations](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/route_declarations.md).

## Related packages

- [yx_navigation](https://pub.dev/packages/yx_navigation) — Dart-only core
- [yx_scope](https://pub.dev/packages/yx_scope), [yx_state](https://pub.dev/packages/yx_state) — **yx_architecture** ecosystem
