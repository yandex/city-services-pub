# yx_state_flutter

Flutter widgets for [yx_state](https://github.com/yandex/yx_state).

## Installation

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  yx_state_flutter: <version>
```

## Widgets

The package provides several widgets to help you manage state in your Flutter application:

### StateBuilder

A widget that rebuilds its UI in response to state changes.

```dart
StateBuilder<LoginController, LoginState>(
  stateReadable: loginController,
  builder: (context, state, child) {
    return Text('Current status: ${state.status}');
  },
)
```

### StateListener

A widget that performs side effects in response to state changes without rebuilding the UI.

```dart
StateListener<LoginController, LoginState>(
  stateReadable: loginController,
  listener: (context, state) {
    if (state.status == LoginStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Error')),
      );
    }
  },
  ...
)
```

### StateConsumer

A widget that combines both StateBuilder and StateListener functionality.

```dart
StateConsumer<LoginController, LoginState>(
  stateReadable: loginController,
  listener: (context, state) {
    if (state.status == LoginStatus.success) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  },
  builder: (context, state, child) {
    return LoginForm(isLoading: state.status == LoginStatus.loading);
  },
)
```

### StateSelector

A widget that rebuilds only when specific parts of the state change.

```dart
StateSelector<LoginController, LoginState, String>(
  stateReadable: loginController,
  selector: (state) => state.errorMessage,
  builder: (context, errorMessage, child) {
    return errorMessage != null
        ? Text(errorMessage, style: TextStyle(color: Colors.red))
        : SizedBox.shrink();
  },
)
```
