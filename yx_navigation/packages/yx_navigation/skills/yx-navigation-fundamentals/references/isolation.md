# yx_navigation: feature isolation and mutating branches

## Feature isolation through a scheme

A feature is a `RouterSchema` of its own. Connect it through `RouteDeclaration.scheme`.

```dart
RouteDeclaration.scheme(route: AppRoutes.profile, schema: ProfileNavigationSchema())
```

- **Standalone** (the feature runs as its own app or example): the feature creates the root `RouteNodeStateManager` itself.
- **Embedded** (the feature runs inside a host): the host passes a `NavigationController.node`:

```dart
final profileNavigationController = NavigationController.node(
  stateManager: appStateManager,
  nodeResolver: RouteNodeResolver.id(route: AppRoutes.profile),
);
RouteDeclaration.scheme(
  route: AppRoutes.profile,
  schema: ProfileNavigationSchema(),
  navigationController: profileNavigationController,
);
```

Or through an `outletBuilder`, when besides the controller you also need to wrap the navigator into a DI scope.

**What isolation provides:** the feature sees and mutates only its own branch of the tree and knows nothing about the host. Schemes nest into one another (`RouteDeclaration.scheme` inside `declarations`).

**Rule:** give routes unique names with a prefix (`account-`, `profile-`) - id collisions between schemes are not resolved automatically yet.

## Mutating inactive branches

The key capability of the package, and the one go_router and auto_route do not have. A controller bound to an inactive branch mutates it from pure Dart, with no `BuildContext`:

```dart
final ordersController = NavigationController.node(
  stateManager: rootStateManager,
  nodeResolver: RouteNodeResolver.id(route: AppRoutes.ordersTab),
);
ordersController.push(AppRoutes.orderCard, arguments: {'orderId': 'ORD-001'});
```

When the user switches to that tab, they see an up-to-date stack with everything that was pushed while the tab was inactive. This is exactly why the navigation state is a tree.
