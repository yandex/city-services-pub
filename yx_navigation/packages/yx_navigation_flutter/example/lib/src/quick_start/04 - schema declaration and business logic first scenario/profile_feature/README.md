# Profile Feature - nested driver-profile feature

This folder contains the **isolated profile feature** that mounts into the host DriverApp as a nested navigation schema.

## Feature layout

```text
profile_feature/
  main.dart                                   # Standalone mode entry point
  profile_feature_dependencies.dart           # Feature DI container
  profile_routes.dart                         # Feature routes (isolated)
  profile_navigation_interactor.dart          # Feature navigation interactor
  profile_navigation_schema.dart              # Profile navigation schema
  profile_skeleton_page.dart                  # Profile UI
  README.md                                   # Feature documentation
```

## What each piece does

### ProfileNavigationInteractor

- **Drives navigation** inside the profile feature
- **Works in two modes:** standalone (owns a RouteNodeStateManager) and embedded (uses a NavigationController.node)
- **Stays isolated** from the host DriverApp
- **Exposes methods** for the feature's business logic

### ProfileFeatureDependencies

- **DI container** for the profile feature
- **Supports two modes:**
  - `standalone()` - creates its own RouteNodeStateManager
  - `embedded()` - accepts a NavigationController from the outside

### ProfileNavigationSchema

- **Declares the feature's routes** (home, driver-profile, trips-history, ...)
- **Adapted** to work with ProfileNavigationInteractor
- **Reuses** the ProfileSkeletonPage UI components

### ProfileSkeletonPage

- **UI components** for the profile pages
- **Consumes** ProfileFeatureDependenciesScope
- **Showcases** the two navigation modes

## Integrating with DriverApp

### 1. Mounting through Schema Declaration

4
Same wiring as in `../driver_navigation_schema.dart`:

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

### 2. Embedded mode: who creates the profile interactor?

The host **`DriverAppDependencies`** factory builds `profileNavigationController`
(`NavigationController.node` for `DriverRoutes.profile`).

Inside **`ProfileFeatureDependencies.embedded`**, the feature constructs
**`ProfileNavigationInteractor`** with that controller — the host does not
create `ProfileNavigationInteractor` directly.

### 3. Standalone mode

```dart
// In profile_feature_dependencies.dart (standalone factory)
final dependencies = ProfileFeatureDependencies.standalone();
// Automatically creates its own RouteNodeStateManager
```

## Why isolation pays off

### Modularity

- The feature can be developed **independently** from the host
- It can be **reused** across different applications
- There are **clear boundaries** of responsibility

### Encapsulation

- The feature manages **only its slice of state**
- It has **no impact** on the host DriverApp navigation
- Its business logic is **self-contained**

### Flexibility

- The implementation can be **replaced** without touching the host
- It is **easy to test** in isolation
- It **slots into** different contexts with minimal glue
