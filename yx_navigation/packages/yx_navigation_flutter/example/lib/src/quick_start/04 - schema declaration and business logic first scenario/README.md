# Schema Declaration + Business Logic First - Driver app

This example shows how to **combine** YX Navigation approaches: Schema Declaration plus Business Logic First.

## What it demonstrates

### The core idea: combining approaches

This example solves a tricky problem: how to drive navigation in an app where

- the **host application** needs the business-logic-first approach
- the **nested features** are mounted via schema declarations
- **different parts of the app** are controlled by navigation controllers scoped to their own state node, all inside a single shared state

### The architectural answer

```dart
// 1) Root state + guard wiring (see DriverAppDependencies factory).
final stateManager = RouteNodeStateManager(
  routeNode: DriverRoutes.login.toNode(),
  routeNodeGuard: routeNodeGuard,
);

// 2) Controller scoped to the profile subtree in the same RouteNodeStateManager.
final profileNavigationController = NavigationController.node(
  stateManager: stateManager,
  nodeResolver: RouteNodeResolver.id(route: DriverRoutes.profile),
);

// 3) Host interactor uses the root state manager as RouteNavigator.
final driverInteractor = DriverNavigationInteractor(
  stateManager: stateManager,
);

// 4) Nested profile schema (declared in driver_navigation_schema.dart).
RouteDeclaration.scheme(
  route: DriverRoutes.profile,
  schema: ProfileNavigationSchema(),
  outletBuilder: (context, state, outlet) {
    return ProfileFeatureDependenciesScope.embedded(
      navigationController: profileNavigationController,
      child: outlet,
    );
  },
);
```

## Key components

### 1. DriverNavigationInteractor

```dart
class DriverNavigationInteractor {
  final RouteNodeStateManager _stateManager;

  RouteNodeStateManager get stateManager => _stateManager;
  RouteNavigator get navigator => _stateManager;

  DriverNavigationInteractor({required RouteNodeStateManager stateManager})
      : _stateManager = stateManager;

  // Host navigation (login, home, orders, messages, profile push with args).
}
```

### 2. ProfileNavigationSchema

```dart
class ProfileNavigationSchema extends RouterSchema {
  ProfileNavigationSchema() : super(
    initialNodeBuilder: (node) {
      // Read arguments to decide the initial state
      final initialPage = node.arguments['initialPage'] ?? 'home';
      // Build the matching page stack
    }
  );
}
```

### 3. DriverAppDependencies (DI)

```dart
final class DriverAppDependencies {
  final RouteNodeStateManager stateManager;
  final LateInitGuardConfiguration routeNodeGuard;
  final NavigationController profileNavigationController;
  final DriverNavigationInteractor driverInteractor;

  // Built in DriverAppDependencies(): state manager + profile subtree
  // controller + host interactor (see driver_app_dependencies.dart).
}
```

### 4. Schema declaration with smart constructors

As in `driver_navigation_schema.dart`:

```dart
final profileSchemaDeclaration = RouteDeclaration.scheme(
  route: DriverRoutes.profile,
  schema: ProfileNavigationSchema(),
  outletBuilder: (context, state, outlet) {
    final profileNavigationController =
        DriverAppDependenciesScope.of(context).profileNavigationController;

    return ProfileFeatureDependenciesScope.embedded(
      navigationController: profileNavigationController,
      child: outlet,
    );
  },
);
```

### 5. Smart constructors for ProfileFeatureDependenciesScope

```dart
final class ProfileFeatureDependenciesScope extends InheritedWidget {
  // Standalone mode - builds its own dependencies.
  factory ProfileFeatureDependenciesScope.standalone({
    required Widget child,
  });

  // Embedded mode - builds dependencies with an external controller.
  factory ProfileFeatureDependenciesScope.embedded({
    required NavigationController navigationController,
    required Widget child,
  });
}
```

## Why it is powerful

### Full control over navigation

- **Before the UI exists:** business logic can invoke navigation
- **While the UI runs:** interactors drive navigation
- **Isolated management:** features are driven through route arguments

### Maximum feature isolation

- **The host app** does not import a feature's internal classes
- **Smart constructors** let features build their own dependencies
- **Clear separation:** the public API (NavigationController) is the only contact surface
- **Reusability:** features are black boxes with a minimal contract

### Coordination

- **Single source of truth:** every controller shares one RouteNodeStateManager
- **Delegation:** the host passes parameters through arguments
- **Isolation:** features are fully autonomous and unaware of one another

## How it comes together

### 1. Initialization (Business Logic First)

```dart
void main() {
  final dependencies = DriverAppDependencies();

  // Demo: schedule navigation before MaterialApp (see main.dart).
  _demonstrateBusinessLogicNavigation(dependencies);

  runApp(
    DriverAppDependenciesScope(
      dependencies: dependencies,
      child: const DriverApp(),
    ),
  );
}
```

### 2. UI integration (Schema Declaration)

```dart
@override
void initState() {
  super.initState();

  debugPanelModeNotifier = DebugPanelModeNotifier(enableDebugPanel: true);

  final dependencies = DriverAppDependenciesScope.of(context, listen: false);
  final stateManager = dependencies.stateManager;

  final driverSchema = DriverNavigationSchema();
  dependencies.routeNodeGuard.attach(
    'driverSchema',
    driverSchema.buildGuards(),
  );

  config = driverSchema.build(
    stateManagerConfiguration: StateManagerConfiguration(
      stateManager: stateManager,
    ),
    debugConfiguration: NavigationDebugConfiguration(
      debugPanelModeNotifier: debugPanelModeNotifier,
    ),
  );
}
```

### 3. Navigation in the host app

```dart
// In DriverSkeletonPage
final driverInteractor =
    DriverAppDependenciesScope.of(context).driverInteractor;

driverInteractor.openProfile();
driverInteractor.performLogin();
```

### 4. Navigation in a nested feature

```dart
// In ProfileSkeletonPage
final profileInteractor =
    ProfileFeatureDependenciesScope.of(context).profileInteractor;

profileInteractor.openDriverProfile();
// …other ProfileNavigationInteractor methods
```

## Compared with the other examples

| Example | Approach | Where state is built | Navigation control |
| -------- | -------- | ------------------- | ---------------------- |
| **01** | Flutter First | In the UI (initState) | YxNavigation.navigatorOf(context) |
| **02** | Business Logic First | In the interactor | ProfileNavigationInteractor |
| **03** | Schema Declaration | In the UI (initState) | YxNavigation.navigatorOf(context) |
| **04** | **Combined** | **In the interactor** | **Through specialized controllers** |

## File layout

```dart
04 - schema declaration and business logic first scenario/
  main.dart                              # Entry point with a demo
  driver_app_dependencies.dart           # DI container
  driver_routes.dart                     # Host-app routes
  driver_navigation_interactor.dart      # Root navigation interactor
  driver_navigation_schema.dart          # Schema with nested features
  driver_skeleton_page.dart              # Host-app UI
  profile_feature/                       # Nested profile feature
    profile_feature_dependencies.dart    # Feature DI container
    profile_navigation_interactor.dart   # Feature navigation interactor
    profile_navigation_schema.dart       # Adapted profile schema
    profile_skeleton_page.dart           # Feature UI
    README.md                            # Feature docs
  README.md                              # This document
```

## When to use this approach

### Great fit for

- **Large applications** with many features
- **Multiple teams** working on different modules
- **Complex navigation business logic**
- **Features reused** across apps
- **Driving navigation before the UI exists**

### Overkill for

- Simple apps with linear navigation
- Prototypes and MVPs
- Apps without reusable modules

## What to explore in the demo

Run the example and try:

1. **Business logic panel** - drive navigation from the interactor
2. **Profile controls** - isolated profile navigation
3. **Coordination** - see how the host delegates to the profile
4. **Navigation info** - inspect state across levels
