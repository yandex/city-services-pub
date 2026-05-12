# Deeplink Handling Scenario

This example demonstrates deeplink handling using `DeeplinkHandler` in YX Navigation.

## Concept

`DeeplinkHandler` allows intercepting incoming URIs before standard parsing and:

- Navigate to a specific screen
- Push a screen on top of the current state
- Execute logic without navigation (handled)
- Filter unwanted deeplinks

## Handler Results

### `DeeplinkHandlerResult.navigate(node)`

Used when the deeplink corresponds to a specific screen. The package will apply the provided `node` as the new navigation stack.

```dart
if (uri.path == '/order_details') {
  final newState = RouteNode.fromRoute(
    route: const YxRoute(id: 'root'),
    children: [
      RouteNode.fromRoute(route: DriverRoutes.home),
      RouteNode.fromRoute(route: DriverRoutes.orderDetails),
    ],
  );
  return DeeplinkHandlerResult.navigate(newState);
}
```

### `DeeplinkHandlerResult.handled()`

Used when the deeplink performs a side effect (showing an alert, saving a token, analytics), but the user should stay on the current screen.

```dart
if (uri.path == '/alert') {
  showSnackBar('Alert!');
  return const DeeplinkHandlerResult.handled();
}
```

The browser URL will be restored to the current screen.

### `null`

If the handler returns `null`, the deeplink is passed to the standard parser.

## Pushing on Top of Current State

To add a screen on top of the current state, use `currentState.toMutable()`:

```dart
if (uri.path == '/settings') {
  final mutableState = currentState.toMutable();
  mutableState.add(RouteNode.fromRoute(route: DriverRoutes.settings));
  return DeeplinkHandlerResult.navigate(mutableState);
}
```

## Error Handling

If `DeeplinkHandler` throws an exception, it will be caught in `YxRouteInformationParser`, logged (in debug mode), and processing will continue with the standard parser.

## Integration

As in `main.dart`: handlers live on the schema, observer/router/navigator
options are passed into `build`:

```dart
final schema = DriverNavigationSchema(
  deeplinkHandlers: [
    AppDeeplinkHandler(
      scaffoldMessengerKey: _scaffoldMessengerKey,
    ),
  ],
);
_config = schema.build(
  debugConfiguration: NavigationDebugConfiguration(
    debugPanelModeNotifier: _debugPanelModeNotifier,
    defaultDisplayType: DebugPanelDisplayType.splitTrailing,
  ),
  routerConfiguration: const RouterConfiguration(
    deeplinkObserver: AppDeeplinkHandlerObserver(),
  ),
  navigatorConfiguration: NavigatorConfiguration(
    navigatorBuilder: (context, outlet) => /* wrap outlet */,
  ),
);
```

## Testing

Run the example in a browser and enter in the address bar:

- `/order_details?id=42` — navigate to order details screen
- `/settings` — push settings screen
- `/alert?msg=Hello` — show a SnackBar
- `/crash` — demonstrate error handling
