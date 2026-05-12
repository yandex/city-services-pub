# yx_navigation

<div align="center">

<img src="https://github.com/yandex/city-services-pub/blob/main/yx_navigation/assets/logos/yx_navigation.webp?raw=true" width="200" alt="The yx_navigation package logo" />

**Dart core for declarative navigation — route tree state, mutations, guards, serialization.**

[![Pub Version](https://img.shields.io/pub/v/yx_navigation)](https://pub.dev/packages/yx_navigation)

</div>

---

Pure Dart library (no Flutter SDK): defines the navigation state model (`RouteNode`),
`RouteNodeStateManager` / controller APIs, guards, observers, and URI-related serialization. Use it to
drive navigation logic without Flutter widgets.

For `Router`, widgets, and Flutter integration, add **[yx_navigation_flutter](https://pub.dev/packages/yx_navigation_flutter)**.

## Install

```yaml
dependencies:
  yx_navigation: ^1.0.0
```

## Documentation

Guides for the whole stack live in the repository **[docs/](https://github.com/yandex/city-services-pub/tree/main/yx_navigation/docs)** folder. Start with
[Quick start](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/quick_start.md) and
[Architecture](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/quick_architecture.md).

## How to start

### Minimal Flutter-first setup

Add **[yx_navigation_flutter](https://pub.dev/packages/yx_navigation_flutter)** for `Router`,
**`RouterSchema`**, and widgets. Outline: routes + declarations → **`schema.build()`** →
**`MaterialApp.router`**; dispose **`YxRouterConfig`** when the owning `State` goes away:

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

The same **`push`** is available from UI via **`YxNavigation.navigatorOf(context)`** (from **yx_navigation_flutter**). The home screen in the example uses it on a button press; you can also call it in a standalone snippet:

```dart
YxNavigation.navigatorOf(context).push(Routes.detail);
```

See **`YxNavigation`** for **`mutatorOf`**, **`navigationControllerOf`**, and related lookups.

### Business Logic First

Keep a **`RouteNodeStateManager`** outside the widget tree—create it in DI or interactors—then pass it into **`schema.build`**:

```dart
profileSchema.build(
  stateManagerConfiguration: StateManagerConfiguration(
    stateManager: existingStateManager,
  ),
);
```

Navigate from domain code with the injected manager—no **`BuildContext`**:

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

Navigation (**`push`**, **`mutate`**, **`stream`**) stays available without **`BuildContext`**. Walkthrough: [Quick start](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/quick_start.md).

### Nesting a feature schema (`RouteDeclaration.scheme`)

Reuse a packaged **`RouterSchema`** under one host route by declaring **`RouteDeclaration.scheme`** on the parent schema:

```dart
RouteDeclaration.scheme(
  route: AppRoutes.profile,
  schema: ProfileNavigationSchema(),
);
```

Mix it with ordinary **`routeBuilder`** declarations on the same **`RouterSchema`**. More detail: [Quick start](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/quick_start.md), [Route declarations](https://github.com/yandex/city-services-pub/blob/main/yx_navigation/docs/route_declarations.md).

### State manager and route tree (Dart-only)

Without Flutter you model navigation as a **tree of `RouteNode`** and drive it through
**`RouteNodeStateManager`**, which implements **`NavigationController`** (read current tree, subscribe,
`push` / `pop`, and low-level **`mutate`**).

#### Routes and nodes

Declare stable route ids with **`YxRoute`**, build immutable nodes with **`RouteNode.fromRoute`**
(or the **`RouteExtension.toNode()`** helper), and compose children into a branch of the tree:

```dart
import 'package:yx_navigation/yx_navigation.dart';

abstract final class DemoRoutes {
  static const home = YxRoute(id: 'demo-home');
  static const detail = YxRoute(id: 'demo-detail');
}

void main() async {
  final root = DemoRoutes.home.toNode();

  final navigation = RouteNodeStateManager(routeNode: root);

  navigation.stream.listen((tree) {
    // Immutable snapshot after each mutation
    print(tree);
  });

  navigation.push(DemoRoutes.detail); // imperative stack-style API

  await navigation.close();
}
```

#### `RouteNodeStateManager` and mutation

The manager keeps the latest **`state`** (`RouteNode`) and applies updates through **`mutate`**:
you receive a **`MutableRouteNode`**, change structure or payload, then return an immutable node
(guards may redirect or cancel the transition):

```dart
navigation.mutate((routeNode) {
  routeNode.add(
    DemoRoutes.detail.toNode(arguments: {'from': 'readme'}),
  );
  return routeNode.toImmutable();
});
```

High-level helpers such as **`push`**, **`pop`**, **`pushReplacement`**, etc. are implemented on top of
the same **`mutate`** pipeline, so behavior stays consistent when called from domain code.

#### Types worth remembering

| Type | Role |
| --- | --- |
| **`YxRoute`** | Stable route identity (`id`), used when building nodes and URI serialization. |
| **`RouteNode`** | Immutable/mutable tree node: route + `arguments`, `extra`, nested `children`. |
| **`RouteNodeStateManager`** | Holds current tree, runs guards on mutation, exposes **`stream`** / **`state`**. |
| **`NavigationController`** | Contract combining reading, **`mutate`**, and imperative navigation. |

## Related packages

- [yx_navigation_flutter](https://pub.dev/packages/yx_navigation_flutter) — Flutter bindings and UI
- [yx_scope](https://pub.dev/packages/yx_scope), [yx_state](https://pub.dev/packages/yx_state) — sibling libraries in **yx_architecture**
