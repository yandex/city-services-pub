# RouteDeclaration.scheme demo - Driver app

This example shows how to use **RouteDeclaration.scheme** to mount a nested navigation schema in a Flutter app.

## What it demonstrates

### Key feature: RouteDeclaration.scheme

```dart
// Mount the entire ProfileNavigationSchema as a nested schema.
final profileSchemaDeclaration = RouteDeclaration.scheme(
  route: DriverRoutes.profile,
  schema: ProfileNavigationSchema(), // Reused from scenario 01
);
```

### Architectural wins

1. **Modularity:** each feature can own its own navigation schema
2. **Reuse:** ProfileNavigationSchema can be used in different contexts
3. **Encapsulation:** complex navigation logic lives inside the schema
4. **Scalability:** new features slot in as standalone schemas

## App structure

```text
Driver App
  Login (entry point)
  Home (dashboard)
    Orders
    Messages
    Profile (NESTED SCHEMA)
      Profile Home
      Driver Profile
      Trips History
      Statistics
      Settings
      Documents
```

## Navigation flow

### Main flow

1. **Login** - sign in
2. **Home** - the driver dashboard
3. **Orders / Messages** - core sections
4. **Profile** - this is where the nested schema kicks in

### Profile (nested schema)

1. **Profile Home** - driver profile overview
2. **Driver Profile** - edit personal details
3. **Trips History** - completed trips
4. **Statistics** - earnings and rating analytics
5. **Settings** - app settings
6. **Documents** - document management

## Core concepts

### 1. RouteDeclaration.scheme vs RouteDeclaration.routeBuilder

```dart
// Plain route declaration (one page)
RouteDeclaration.routeBuilder(
  route: DriverRoutes.orders,
  routeBuilder: RouteBuilder.widget(
    builder: (context, state) => OrdersPage(),
  ),
)

// Schema declaration (an entire navigation tree)
RouteDeclaration.scheme(
  route: DriverRoutes.profile,
  schema: ProfileNavigationSchema(), // Full schema with multiple routes
)
```

### 2. Importing schemas from other examples

```text
// Reuse ProfileNavigationSchema from scenario 01
import '../01 - profile - flutter-first-scenario/profile_navigation_schema.dart';
```

### 3. Flutter-first approach

```dart
// YxRouterConfig is built inside the widget's initState (see main.dart).
@override
void initState() {
  super.initState();
  debugPanelModeNotifier = DebugPanelModeNotifier(enableDebugPanel: true);

  final driverSchema = DriverNavigationSchema();
  config = driverSchema.build(
    debugConfiguration: NavigationDebugConfiguration(
      debugPanelModeNotifier: debugPanelModeNotifier,
    ),
  );
}
```

## File layout

```text
03 - schema declaration usage scenario/
  driver_routes.dart              # Route declarations
  driver_navigation_schema.dart   # Schema using RouteDeclaration.scheme
  driver_skeleton_page.dart       # UI component
  main.dart                       # Entry point
  README.md                       # Documentation
```

## Next steps

After going through this example you will be able to:

1. **Build modular navigation schemas** for large apps
2. **Reuse existing features** via RouteDeclaration.scheme
3. **Combine different navigation approaches** inside one app
4. **Scale an app** using nested schemas

## Related examples

- **[01 - profile - flutter-first-scenario](../01%20-%20profile%20-%20flutter-first-scenario/README.md)** - Profile base schema
- **[02 - profile - business-logic-first-scenario](../02%20-%20profile%20-%20business-logic-first-scenario/README.md)** - Business-logic-first approach
