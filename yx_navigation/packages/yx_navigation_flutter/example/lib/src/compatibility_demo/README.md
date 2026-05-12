# Compatibility Mode Demo

Demonstrates YxNavigation's backwards-compatibility layer for the Navigator 1.0 API.

## Overview

This example shows how to use the legacy imperative Navigator 1.0 API (`Navigator.of(context).push()`, `showDialog()`, etc.) inside an application that uses YxNavigation's declarative Navigator 2.0.

## What it covers

### 1. Basic navigation

- `Navigator.of(context).push(MaterialPageRoute(...))`
- `Navigator.of(context).push(CupertinoPageRoute(...))`
- Fullscreen Dialog mode
- Receiving results through `pop(result)`

### 2. Replace operations

Without Compatibility mode these operations trigger an assert.

- `Navigator.of(context).pushReplacement(...)`
- `Navigator.of(context).pushAndRemoveUntil(...)`

### 3. Modal surfaces

- `showDialog()` -> DialogRoute
- `showCupertinoDialog()` -> CupertinoDialogRoute
- `showCupertinoModalPopup()` -> CupertinoModalPopupRoute (Action Sheet)
- `showGeneralDialog()` -> RawDialogRoute (custom animations)
- `showModalBottomSheet()` -> ModalBottomSheetRoute
- `showMenu()` -> PopupMenuRoute (**native mode** - bypasses the compatibility layer)

### Note on showMenu()

**PopupMenuRoute runs in native mode** (the compatibility layer does not support it):

Why:

- `PopupMenuRoute` is a private class in the Flutter SDK
- You cannot wrap it in `PageRouteBuilder` without breaking the overlay/animation pipeline
- Its constructor is not accessible, so a specialized adapter cannot be built

How it behaves:

- YxNavigator detects the unsupported route (`_buildPageFactory` returns `null`)
- `_attachPageFactory` throws `UnsupportedRouteException`
- `YxNavigator.push()` catches it and delegates to `super.push()` (native Navigator)
- The route runs as a pageless route (no integration with YxNavigation state)

What works:

```dart
await showMenu(...);           // Show the menu
Navigator.of(context).pop();   // Close the menu
// Receiving a result from pop() works
```

Limitations:

```dart
await showMenu(...);
Navigator.of(context).pushReplacement(...);  // Assert! Mixing page-based / pageless routes
Navigator.of(context).replace(...);           // Assert! Mixing page-based / pageless routes
```

Why it breaks after `showMenu()`:

- YxNavigation uses page-based routes (every route has a Page)
- `showMenu()` creates a pageless route (no Page)
- Flutter's Navigator forbids `replace` / `pushReplacement` when the two types are mixed
- See `NavigatorState._debugCheckIsPagelessAndMatchesPage()` in the Flutter SDK

Recommendation: use the `PopupMenuButton` widget instead of `showMenu()` for full compatibility.

### 4. Mixing the two approaches

- Page-based routes (RouteDeclaration)
- Pageless routes (Navigator 1.0)
- Both work side by side in the same Navigator

## How to run

### VS Code

1. Open the command palette (Cmd/Ctrl + Shift + P)
2. Select "Debug: Select and Start Debugging"
3. Pick "Compatibility Demo - Navigator 1.0 Integration"

### IntelliJ IDEA

1. In the top panel pick the "Compatibility Demo - Navigator 1.0 Integration" run configuration
2. Click Run (the green arrow)

### Command line

```bash
cd example
flutter run -t lib/src/compatibility_demo/main.dart
```

## The key piece: NavigatorCompatibilityOverrides

`main.dart` composes several observers and passes them to
`NavigatorCompatibilityOverrides` (see `CompositeCompatibilityObserver` there):

```dart
NavigationConfigProvider(
  navigatorOverrides: NavigatorCompatibilityOverrides(
    observer: compatibilityObserver, // e.g. CompositeCompatibilityObserver([...])
  ),
  child: MaterialApp.router(
    routerConfig: config,
  ),
)
```

### CompatibilityObserver

`CompatibilityObserver` is the observer pattern used to monitor compatibility-layer events:

Three event types:

1. **`willPushPagelessRoute`** - fires before the route is processed
   - Return `false` to block processing
   - Receives `routeNodeReadable` for access to the current navigation state
   - Useful for validation and logging

2. **`didCreatePagelessRoute`** - fires after a successful creation
   - Receives the fully-populated `RouteNode`
   - Receives `routeNodeReadable` for the parent node
   - Useful for analytics and debugging

3. **`didFailPagelessRoute`** - fires on a creation failure
   - Called by `YxNavigator` before the fallback to the native Navigator
   - Receives the error (`UnsupportedRouteException`)
   - `routeNode` is always `null` (the route was never built)
   - Useful for error tracking and monitoring

**DebugCompatibilityObserver:**

- Logs every pageless route at every stage
- Shows the current navigation state (`routeNodeReadable.state`)
- Counts successful and failed routes
- Helps debug the integration

**MigrationTrackingObserver:**

- Collects route-type stats
- Helps track migration progress toward Navigator 2.0
- `printReport()` prints the report when the app shuts down

**Example of a custom observer:**

```dart
class AnalyticsCompatibilityObserver extends CompatibilityObserver {
  @override
  bool willPushPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
  }) {
    // Read the current navigation state.
    final currentState = routeNodeReadable.state;

    // Log the push attempt.
    analytics.trackEvent('route_will_push', {
      'route_id': routeId,
      'route_type': route.runtimeType.toString(),
      'current_route': currentState.path,
    });

    return true; // Allow processing.
  }

  @override
  void didCreatePagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
    required String routeType,
    required RouteNode routeNode,
  }) {
    // Report a detailed analytics event.
    analytics.trackEvent(
      'legacy_route_created',
      properties: {
        'route_type': routeType,
        'route_name': route.settings.name,
        'route_path': routeNode.path,
        'has_children': routeNode.children.isNotEmpty,
        'parent_path': routeNodeReadable.state.path,
      },
    );
  }

  @override
  void didFailPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required Object error,
    required RouteNode? routeNode,
  }) {
    // Send the failure to error tracking.
    errorReporting.logError(
      'Route fallback to native Navigator',
      error: error,
      properties: {
        'route_type': route.runtimeType.toString(),
        'route_name': route.settings.name,
        'current_path': routeNodeReadable.state.path,
      },
    );
  }
}
```

**Composite pattern for running several observers at once:**

```dart
class CompositeCompatibilityObserver extends CompatibilityObserver {
  final List<CompatibilityObserver> observers;

  CompositeCompatibilityObserver(this.observers);

  @override
  bool willPushPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route route,
    required String routeId,
  }) {
    // Every observer must return true.
    return observers.every((o) => o.willPushPagelessRoute(
      routeNodeReadable: routeNodeReadable,
      route: route,
      routeId: routeId,
    ));
  }

  @override
  void didCreatePagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route route,
    required String routeId,
    required String routeType,
    required RouteNode routeNode,
  }) {
    for (final observer in observers) {
      observer.didCreatePagelessRoute(
        routeNodeReadable: routeNodeReadable,
        route: route,
        routeId: routeId,
        routeType: routeType,
        routeNode: routeNode,
      );
    }
  }

  @override
  void didFailPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route route,
    required Object error,
    required RouteNode? routeNode,
  }) {
    for (final observer in observers) {
      observer.didFailPagelessRoute(
        routeNodeReadable: routeNodeReadable,
        route: route,
        error: error,
        routeNode: routeNode,
      );
    }
  }
}

// Usage:
final debugObserver = DebugCompatibilityObserver();
final migrationObserver = MigrationTrackingObserver();

navigatorOverrides: NavigatorCompatibilityOverrides(
  observer: CompositeCompatibilityObserver([
    debugObserver,
    AnalyticsCompatibilityObserver(),
    migrationObserver,
  ]),
),

// You can still call methods on individual observers:
@override
void dispose() {
  migrationObserver.printReport(); // Prints the migration report
  super.dispose();
}
```

## Why do replace operations fail without Compatibility?

Flutter's Navigator SDK distinguishes between two route kinds:

- **Page-based routes** - created from Page objects (Navigator 2.0 declarative style)
- **Pageless routes** - created via push / showDialog (Navigator 1.0 imperative style)

On `pushReplacement` / `replace`, the Navigator validates the two kinds are compatible. In YxNavigation every declarative route is page-based (declared with `RouteDeclaration`).

When legacy code calls `pushReplacement` with a fresh `MaterialPageRoute`, the Navigator sees page-based and pageless routes mixed in the stack and raises an assert:

```dart
// From flutter/lib/src/widgets/navigator.dart
assert(() {
  if (route is! Page && ModalRoute.of(context)?.isActive == true) {
    throw FlutterError(
      'Cannot replace a route that is already active.\n'
      'The route is not a Page-based route.'
    );
  }
  return true;
}());
```

**NavigatorCompatibilityOverrides solves this** by wrapping every pageless route in a Page and keeping it in sync with the declarative YxNavigation state.

## File layout

```text
compatibility_demo/
  main.dart                      # App entry point
  navigation_schema.dart         # Navigation schema
  routes.dart                    # Route declarations
  compatibility_observers.dart   # CompatibilityObserver examples
  pages/
    home_page.dart               # Home page with demo buttons
    legacy_detail_page.dart      # Legacy page (pageless route)
    profile_page.dart            # Page-based route for comparison
  README.md                      # This file
```

## Architecture

See the Compatibility architecture document for a detailed breakdown of the mechanism.

### Main components

1. **YxNavigator** - intercepts Navigator 1.0 operations
2. **NavigatorCompatibilityOverrides** - adapts those operations for YxNavigation
3. **CompatibilityObserver** - monitors compatibility-layer events
4. **SourceRouteCompleter** - makes sure routes complete correctly
5. **RouteNodeCompatibilityExtension** - separates page-based from pageless routes
6. **CustomRoutePageFactoryResolver** - extensibility for custom Route subclasses

## When to use Compatibility mode

Use it when:

- Migrating an existing app away from Navigator 1.0
- Integrating third-party libraries that still use Navigator 1.0
- Rolling out a gradual migration across a large codebase

Skip it when:

- Starting a new project - prefer RouteDeclaration from the start
- Working on performance-critical paths - declarative navigation is more efficient
