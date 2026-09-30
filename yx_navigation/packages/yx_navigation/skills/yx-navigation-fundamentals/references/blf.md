# yx_navigation: Business Logic First and the page factory

## Business Logic First (BLF)

Navigate from business logic **without a `BuildContext`**. The `RouteNodeStateManager` is created in an interactor or in DI **before** the UI, and is passed to `schema.build()` through `StateManagerConfiguration`. At the root level the same object is what `YxNavigation.navigatorOf(context, isRoot: true)` returns; plain `navigatorOf(context)` gives the navigator of the current subtree, which inside a nested scheme is a different object.

```dart
class ProfileNavigationInteractor {
  late final RouteNodeStateManager _stateManager;
  RouteNavigator get navigator => _stateManager;

  ProfileNavigationInteractor() {
    _stateManager = RouteNodeStateManager(routeNode: ProfileRoutes.home.toNode());
  }

  void openSettings() => navigator.push(ProfileRoutes.settings);
}
```

```dart
// DI
config = profileSchema.build(
  stateManagerConfiguration: StateManagerConfiguration(stateManager: stateManager),
);
// UI
MaterialApp.router(routerConfig: config);
```

**A state manager built outside the schema does not get the guards of that schema.** When `build()`
creates the manager itself it passes the guards in; when you hand it a ready one through
`StateManagerConfiguration`, that step is skipped and every guard of the scheme is silently
inactive. Pass them yourself:

```dart
final schema = ProfileNavigationSchema();
final stateManager = RouteNodeStateManager(
  routeNode: ProfileRoutes.home.toNode(),
  routeNodeGuard: GuardConfiguration(guards: schema.buildGuards()),
);
```

The schema has to exist before the manager, so build it in DI next to the manager rather than in the
widget that renders the router.

The `RouteNavigator` operations (`push`, `pop` and the others) are synchronous: they return `void` and the tree is updated by the time the call returns. Do not `await` them.

## Recipe: pushing into an inactive branch from an interactor

The interactor receives a `NavigationController.node` that was **assembled in advance**. Resolving the node is the job of DI, not of the interactor - that is what keeps the dependency inversion intact.

```dart
class OrderNotificationInteractor {
  OrderNotificationInteractor({
    required NavigationController ordersBranchController,
    required OrderStateReadable orderState,
  })  : _ordersBranchController = ordersBranchController, _orderState = orderState {
    _subscription = _orderState.stream.listen(_onOrderChanged);
  }

  final NavigationController _ordersBranchController;
  late final StreamSubscription _subscription;

  void _onOrderChanged(OrderState state) {
    if (state.newOrderArrived) {
      _ordersBranchController.push(  // push into an inactive branch, no BuildContext
        AppRoutes.orderCard,
        arguments: {'orderId': state.newOrderId!},
      );
    }
  }

  Future<void> dispose() async => _subscription.cancel();
}
```

```dart
// DI: assemble the branch controller. The `dep(...)` syntax is yx_scope, the DI package of
// this stack; with another container the shape is the same.
late final _ordersBranchControllerDep = dep<NavigationController>(
  () => NavigationController.node(
    stateManager: _routeNodeStateManagerDep.get,
    nodeResolver: RouteNodeResolver.id(route: AppRoutes.ordersTab),
  ),
);
```

## The page factory

A `PageFactory<T>` decides how a `RouteBuilder` turns a widget into a Flutter `Page`.

```dart
RouteBuilder.widget(builder: ..., pageFactory: const PagesFactory.material());   // the default
RouteBuilder.widget(builder: ..., pageFactory: const PagesFactory.cupertino());
// a custom transition or a modal
RouteBuilder.widget(builder: ..., pageFactory: PagesFactory.custom(
  builder: (context, node, key, child) =>
      FadePage(key: key, name: node.route.id, child: child),
));

// The page is yours to write - the package ships no ready-made transition page.
class FadePage extends Page<void> {
  const FadePage({required this.child, required super.key, required super.name});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) => PageRouteBuilder(
        settings: this,
        pageBuilder: (context, animation, secondary) => child,
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
      );
}
```

Reuse one builder with different page factories. Note that `fullscreenDialog: true` is not the same as a `DialogPage`: the first is a full-screen bottom-to-top transition, the second is a modal with a barrier.
