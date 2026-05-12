# Driver profile - Business-Logic-First approach

Demo application that teaches YX Navigation using the **business-logic-first** approach, where business logic owns navigation and the UI follows along.

## Key differences from the Flutter-First approach

### Flutter-First approach (folder 01)

- RouterSchema is created in `initState()`
- RouterConfig is obtained via `schema.build()`
- RouteNavigator becomes available **only after** MaterialApp is built, through `YxNavigation.navigatorOf(context)`
- Navigation is triggered from the UI layer

### Business-Logic-First approach (folder 02)

- RouteNodeStateManager is created up front inside `Dependencies` (DI container)
- RouteNavigator is available through the state manager **before** MaterialApp is built
- Business logic drives navigation independently of the UI
- Navigation can be triggered from business processes

## Project layout

```text
02 - profile - business-logic-first-scenario/
  main.dart                            # Entry point with a short demo
  dependencies.dart                     # Scope and Dependencies
  profile_navigation_interactor.dart    # Pure Dart business logic
  profile_navigation_schema.dart        # Navigation schema
  profile_routes.dart                   # Route constants
  profile_skeleton_page.dart            # UI page
  README.md                             # This file
```

## Architecture

### Dependencies (DI container)

**Owns creation and wiring of dependencies**:

- Builds the root RouteNodeStateManager with the initial state
- Creates ProfileNavigationInteractor and injects the state manager
- Exposes the RouteNodeStateManager directly via `DependenciesScope.of(context).stateManager`

### ProfileNavigationInteractor

**Contains business logic only**, no Flutter dependencies:

- Accepts a pre-built RouteNodeStateManager through its constructor (dependency injection)
- Exposes navigation methods for business processes
- Can drive navigation before the UI exists

### Wiring state into the UI

The **pre-built** `RouteNodeStateManager` from `DependenciesScope` is passed into
`RouterSchema.build` via `StateManagerConfiguration` (same pattern as
scenario **04**):

```dart
final stateManager =
    DependenciesScope.of(context, listen: false).stateManager;

final profileSchema = ProfileNavigationSchema();
config = profileSchema.build(
  stateManagerConfiguration: StateManagerConfiguration(
    stateManager: stateManager,
  ),
  debugConfiguration: NavigationDebugConfiguration(
    debugPanelModeNotifier: debugPanelModeNotifier,
    defaultDisplayType: DebugPanelDisplayType.splitTrailing,
  ),
  navigatorConfiguration: NavigatorConfiguration(
    navigatorBuilder: (context, outlet) => /* ... */,
  ),
);
```

See `main.dart` in this folder for the full `initState` implementation.

## Technical notes

### Separation of concerns

- **ProfileNavigationInteractor** - uses only `yx_navigation`, no Flutter
- **UI layer** - consumes a ready-made RouteNodeStateManager and produces the RouterConfig
- **Dependencies** - binds business logic to the UI

### Lifecycle

1. **main()** - build Dependencies:
   - RouteNodeStateManager is created with the initial state
   - ProfileNavigationInteractor receives the state manager via its constructor
2. **Demo** - call navigation methods before MaterialApp is built
3. **initState()** - fetch the prepared state manager from Dependencies
4. **build()** - construct the RouterConfig from the prepared state manager

### Why this matters

- **Testability** - business logic is isolated from the UI
- **Reuse** - the interactor can power different UIs
- **Independence** - navigation runs without a Flutter context
- **Flexibility** - complex business scenarios are easy to express
- **Dependency injection** - clear layer boundaries
- **No GlobalKey conflicts** - the state manager is owned centrally

## For developers

### Adding a new route

1. Add a constant to `ProfileRoutes`
2. Create a declaration in `ProfileNavigationSchema`
3. Add a method to `ProfileNavigationInteractor`
4. Optionally add a button to `_buildBusinessLogicControls`

## Comparison

| Aspect | Flutter-First | Business-Logic-First |
| ------ | ------------- | -------------------- |
| **Where the navigator is built** | In initState() | In Dependencies (DI) |
| **When navigation is available** | After MaterialApp | Before MaterialApp |
| **Testing business logic** | Hard | Easy |
| **Dependency injection** | Not required | Constructor-based |
| **Complex scenarios** | Through UI callbacks | Directly in the interactor |
| **Flutter dependency** | Inside the navigation schema | Only in the UI layer |
| **Reusability** | Limited | High |

## When to use Business-Logic-First

### A good fit when

- You have complex business processes tied to navigation
- The app performs automatic transitions
- You want a modular architecture with reusable pieces
- Testability is a hard requirement

### Overkill when

- The app only has simple, user-driven navigation
- The project is a prototype or throwaway demo
- There is no meaningful business logic

## Next steps

1. Read through `ProfileNavigationInteractor` - the heart of the approach
2. Run the app and watch the console logs
3. Experiment with additional business scenarios
4. Compare the code with the Flutter-First variant in folder 01
5. Adapt the pattern to your own project
