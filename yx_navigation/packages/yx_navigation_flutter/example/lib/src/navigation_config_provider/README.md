# NavigationConfigProvider Demo

Demo application that shows how to override navigation configuration through `NavigationConfigProvider`.

## Example architecture

### Host application + nested schema

The example uses a **host app + nested schema** architecture, which mirrors a real-world setup in large applications:

```text
Host App
  Home
  Settings
  About
  Profile - nested schema via RouteDeclaration.scheme
    Profile Home
    Driver Profile
    Trips History
    Statistics
    Profile Settings
    Documents
```

### Key idea

The **host application** uses default Material navigation configuration, while the **nested profile schema** can override that configuration through `NavigationConfigProvider` inside its `outletBuilder`.

## Demo modes

The app supports six demo modes that you can switch between using the settings icon in the AppBar:

### 1. Standard configuration

- Material pages
- Default transition animations
- Default NotFound / Empty widgets

### 2. Cupertino pages

- **Override:** `defaultPageFactory: PagesFactory.cupertino()`
- iOS-style pages instead of Material
- Matching transition animations

### 3. No animations

- **Override:** `transitionDelegate: NoAnimationTransitionDelegate()`
- Instant transitions, no animation
- Everything else is default

### 4. Custom widgets

- **Override:** `widgetBuilder: CustomRouteNodeWidgetBuilder()`
- Custom NotFound and Empty pages
- Everything else is default

### 5. Fade animations

- **Overrides:**
  - `transitionDelegate: FadeTransitionDelegate()`
  - `defaultPageFactory: FadePageFactory()`
- Smooth fade transitions between pages

### 6. Combined

- **Overrides:**
  - `transitionDelegate: FadeTransitionDelegate()`
  - `defaultPageFactory: PagesFactory.cupertino()`
  - `widgetBuilder: CustomRouteNodeWidgetBuilder()`
- A combination of every customization

## Technical implementation

### RouteDeclaration.scheme with outletBuilder

The key piece is using `outletBuilder` to override the configuration:

```dart
RouteDeclaration.scheme(
  route: HostRoutes.profile,
  schema: ProfileSchema(),
  outletBuilder: (context, state, outlet) {
    return ValueListenableBuilder<DemoMode>(
      valueListenable: demoModeNotifier,
      builder: (context, demoMode, child) {
        // Override defaults for the nested schema.
        return NavigationConfigProvider(
          defaults: DemoConfigurations.getConfiguration(demoMode),
          child: outlet,
        );
      },
    );
  },
)
```

### Configuration isolation

- **Host application:** always uses the standard Material configuration
- **Nested profile schema:** uses overridden configuration depending on the selected mode
- The two configurations are isolated, so profile changes never leak to the host

### Runtime switching

You can switch modes at runtime:

1. `ValueNotifier<DemoMode>` tracks the current mode
2. `ValueListenableBuilder` rebuilds `NavigationConfigProvider` when the mode changes
3. New configuration applies only to the nested profile schema

## File layout

```text
navigation_config_provider/
  main.dart                           # Main app entry point
  host_app_schema.dart                # Host app schema
  host_routes.dart                    # Host routes
  host_pages.dart                     # Host pages + mode switcher
  demo_configurations.dart            # Configurations for each mode
  custom_implementations.dart         # Custom implementations
  profile_feature/                    # Nested profile schema
    profile_schema.dart               # Profile schema
    profile_routes.dart               # Profile routes
    profile_pages.dart                # Profile pages
  README.md                           # This document
```

## How to run

1. Change into the example directory:

   ```bash
   cd example/
   ```

2. Launch the app:

   ```bash
   flutter run lib/src/navigation_config_provider/main.dart
   ```

3. Web browser is recommended for the smoothest demo experience

## How to use

1. **Explore the host app:** the host always uses the default Material configuration

2. **Enter the profile:** tap "Driver profile (nested schema)" on the home page

3. **Switch modes:** use the settings icon in the AppBar to cycle through the modes

4. **Try the showcase widgets:**
   - Tap "Navigate to a non-existent route" to show the Not Found widget
   - Tap "Show the empty widget" to show the Empty widget
   - The host renders the default widgets (they change with the current mode)
   - The profile renders the custom widgets (red for Not Found, orange for Empty)

5. **Compare behavior:**
   - The host navigation stays constant
   - The profile navigation changes with the selected mode
   - Pay attention to animations, page style and the overridden widgets

6. **Use the debug panel:** it is on by default and helps inspect the navigation state

## Real-world use cases

The example reflects a realistic setup in large apps:

- **Modular architecture:** teams can develop the host and individual modules independently
- **Isolated configuration:** each module can own its navigation configuration
- **Reusability:** modules can be used across applications
- **Flexibility:** configuration can change at runtime or be fixed

## What NavigationDefaults can override

Through `NavigationDefaults` you can override:

- **transitionDelegate** - transition animations between pages
- **defaultPageFactory** - page-creation factory (Material, Cupertino, custom)
- **widgetBuilder** - widgets for NotFound, Empty and other states
- **localKeyFactory** - key creation for pages (not shown in this example)

You can combine these to give every module a tailored navigation experience.
