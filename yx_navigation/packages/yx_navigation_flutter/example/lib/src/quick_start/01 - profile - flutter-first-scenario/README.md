# Driver profile - Quick Start

Demo application that teaches YX Navigation through a driver-profile section.

## Project layout

```text
01 - profile - flutter-first-scenario/
  main.dart                       # App entry point
  profile_navigation_schema.dart # Navigation schema and routes
  profile_skeleton_page.dart     # Base page with skeleton UI
  README.md                      # This file
```

## Running the app

Target path (folder name contains spaces — **quote** the `-t` argument):

```text
lib/src/quick_start/01 - profile - flutter-first-scenario/main.dart
```

### From the example project root

```bash
cd example
fvm flutter run -t "lib/src/quick_start/01 - profile - flutter-first-scenario/main.dart"
```

### For the web

```bash
cd example
fvm flutter run -d chrome -t "lib/src/quick_start/01 - profile - flutter-first-scenario/main.dart"
```

### For the iOS simulator

```bash
cd example
fvm flutter run -d "iPhone Simulator" -t "lib/src/quick_start/01 - profile - flutter-first-scenario/main.dart"
```

### For an Android emulator

```bash
cd example
fvm flutter run -d android -t "lib/src/quick_start/01 - profile - flutter-first-scenario/main.dart"
```

## Useful commands

### Check available devices

```bash
cd example
fvm flutter devices
```

### Hot reload (during development)

```dart
r - hot reload
R - hot restart
q - quit
```

### Analyze

```bash
cd example
fvm flutter analyze
```

### Format

```bash
cd example
fvm dart format "lib/src/quick_start/01 - profile - flutter-first-scenario/"
```

## What it demonstrates

### Navigation schema

- **ProfileNavigationSchema** - the main navigation schema
- **ProfileRoutes** - route constants
- **RouteDeclaration.routeBuilder** - page declarations

### Pages

- **My profile** (home) - section overview
- **Driver profile** - personal details
- **Trips history** - completed orders
- **Statistics** - earnings analytics
- **Settings** - app configuration
- **Documents** - document management

### UI components

- **ProfileSkeletonPage** - page with a skeleton loading UI

## Highlights

- **Self-contained** - all files live in one folder
- **Debug panel** - built-in navigation debugger
- **Web support** - runs in the browser
- **Skeleton UI** - shows loading states
- **Navigation 2.0** - modern Flutter routing

## Architecture

```text
MaterialApp.router
  ProfileNavigationSchema
    ProfileRoutes.home (home)
      ProfileRoutes.driverProfile
      ProfileRoutes.tripsHistory
      ProfileRoutes.statistics
      ProfileRoutes.settings
      ProfileRoutes.documents
```

## Requirements

- **Flutter SDK** (FVM is recommended)
- **Chrome** for the web target
- **VS Code / IntelliJ** with the Flutter plugins (recommended)

### If FVM is unavailable

Use plain `flutter` commands instead of `fvm flutter`:

```bash
# Instead of: fvm flutter run -d chrome -t "lib/src/quick_start/01 - profile - flutter-first-scenario/main.dart"
flutter run -d chrome -t "lib/src/quick_start/01 - profile - flutter-first-scenario/main.dart"
```

## Extras

- **Debug panel** is available in debug mode (button in the corner)
- **URL navigation** works on the web - browser back/forward buttons are supported
- **Back button** is handled correctly on every platform
- **Hot reload** works for both UI and navigation changes
- **Factory constructors** - modern `RouteDeclaration.routeBuilder` is used instead of the deprecated form
