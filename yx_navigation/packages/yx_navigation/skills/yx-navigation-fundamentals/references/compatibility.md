# yx_navigation: interop with Navigator 1.0

You need this during a migration, so that old `Navigator` code keeps working next to yx_navigation. Enable it like this:

```dart
NavigationConfigProvider(
  navigatorOverrides: const NavigatorCompatibilityOverrides(),
  child: MaterialApp.router(routerConfig: config),
)
```

After that the old `Navigator.of(context).push(...)`, `showDialog` and `showModalBottomSheet` all work.

- **Work without the compatibility layer:** `push`, `pop`, `canPop`, `maybePop` - they simply add or remove the top of the stack.
- **Require the compatibility layer** (otherwise they assert): `pushReplacement`, `pushAndRemoveUntil`, `removeRoute`, `replace`, `replaceRouteBelow`.
- **Coverage is about 95%:** `MaterialPageRoute`, `CupertinoPageRoute` and `ModalBottomSheetRoute` are fully covered; `DialogRoute`, `CupertinoDialogRoute`, `RawDialogRoute` and `CupertinoModalPopupRoute` have dedicated adapters; an arbitrary `ModalRoute` falls back to `modalRouteProxy`.
- **Not supported:** `PopupMenuRoute` (`showMenu`) - it is a private SDK class. Use `PopupMenuButton`, `DropdownButton`, your own overlay, or a `CustomRoutePageFactoryResolver` instead.

To extend the coverage, implement a `CustomRoutePageFactoryResolver` (`hasResolverFor` plus `resolvePage`). To track the progress of the migration, observe `CompatibilityObserver.didCreatePagelessRoute`.

**Rule:** always pass `RouteSettings(name: 'unique-name')`, otherwise `routeId` falls back to a timestamp and debugging becomes difficult. What the fallback does with an unsupported `Route`: `push` goes to the native `super.push()`, while `pushReplacement` and `pushAndRemoveUntil` throw an `UnsupportedRouteException` - there is no fallback for those.

## The debug panel

```dart
config = schema.build(
  debugConfiguration: NavigationDebugConfiguration(
    debugPanelModeNotifier: DebugPanelModeNotifier(enableDebugPanel: true),
  ),
);
```

It shows the `RouteNode` tree with `arguments` and `extra`, the active route at every nesting level, the serialized state, and the mutation history. Indispensable when debugging tabs, nested schemes, and the compatibility layer.
