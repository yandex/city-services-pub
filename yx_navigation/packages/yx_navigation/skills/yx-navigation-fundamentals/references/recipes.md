# yx_navigation: scheme recipes and antipatterns

## Antipatterns

| # | Antipattern | Why |
|---|---|---|
| 1 | "Just opening a screen" around the tree | impossible by design - every operation is a mutation |
| 2 | Short or non-unique route ids (`'h'`) | id collisions are not resolved - use descriptive prefixes (`profile-home`) |
| 3 | `RouteBuilder.indexed` without initializing `children` explicitly | no guards are created and the tabs stay empty - use `RouteDeclaration.indexedStack` |
| 4 | Importing the internal classes of a feature from the host | breaks isolation - go through `RouteDeclaration.scheme` plus `NavigationController.node` |
| 5 | Calling the interactor of a feature directly from the host | pass data through the `arguments` of a `push` instead |
| 6 | `pushReplacement` with an unsupported `Route` | it throws, there is no fallback - add a `CustomRoutePageFactoryResolver` |
| 7 | A `MaterialPageRoute` without `RouteSettings(name:)` in compatibility mode | `routeId` falls back to a timestamp and debugging becomes difficult |
| 8 | A guard that holds business logic | guards are policy; orchestration belongs in an Interactor |
| 9 | `RouteDeclaration.scheme` for simple nesting that needs no isolation | unnecessary complexity - use `RouteBuilder.outlet` |

## Recipe: a minimal scheme

```dart
abstract class ProfileRoutes {
  static const home = YxRoute(id: 'profile-home');
  static const settings = YxRoute(id: 'profile-settings');
}

class ProfileNavigationSchema extends RouterSchema {
  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([ProfileRoutes.home.toNode()]);

  // A getter would rebuild the list on every walk, and `build()` walks it three
  // times: for the observers, the guards and the deeplink handlers. Build it once.
  @override
  late final Iterable<RouteDeclaration> declarations = [
    RouteDeclaration.routeBuilder(
      route: ProfileRoutes.home,
      routeBuilder: RouteBuilder.widget(builder: (context, state) => const ProfileHomePage()),
    ),
    RouteDeclaration.routeBuilder(
      route: ProfileRoutes.settings,
      routeBuilder: RouteBuilder.widget(builder: (context, state) => const SettingsPage()),
    ),
  ];
}
```

To start: `_config = ProfileNavigationSchema().build();` and then `MaterialApp.router(routerConfig: _config)`. Do not forget `_config.dispose()`.

## Recipe: tabs with an IndexedStack

```dart
final homeDeclaration = RouteDeclaration.indexedStack(
  route: HomeRoutes.root,
  routeBuilder: RouteIndexedStackBuilder(
    indexedBuilder: (context, routeNode, indexedStack, controller) {
      const tabs = [HomeRoutes.map, HomeRoutes.messages, HomeRoutes.profile];
      final currentIndex = tabs.indexOf(controller.activeRoute ?? HomeRoutes.map);
      return Scaffold(
        body: indexedStack,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => controller.setActiveRoute(tabs[i]),
          items: const [/* ... */],
        ),
      );
    },
  ),
  declarations: [mapTabDeclaration, messagesTabDeclaration, profileTabDeclaration],
);
```

## Recipe: a nested feature module

```dart
class AppNavigationSchema extends RouterSchema {
  @override
  RouteNode initialNodeBuilder(MutableRouteNode node) =>
      node..setChildren([AppRoutes.main.toNode()]);

  @override
  late final Iterable<RouteDeclaration> declarations = [
    mainDeclaration,
    RouteDeclaration.scheme(route: AppRoutes.profile, schema: ProfileNavigationSchema()),
  ];
}
// the transition: YxNavigation.navigatorOf(context).push(AppRoutes.profile);
```

The host knows nothing about the internal routes of `ProfileNavigationSchema`.
