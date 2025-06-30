yx_scope_flutter package is an adapter for yx_scope package for using it with Flutter.

## Features

`ScopeProvider` is an `InheritedWidget` that passes your scope down to any widget in the subtree.

`ScopeBuilder` handles building a widget in response to `scope`.

`ScopeListener` is a widget that should be used for functionality that needs to occur only in
response to a `scope` change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...

`ScopeConsumer` is analogous to a nested `ScopeListener` and `ScopeBuilder` but reduces the amount
of boilerplate needed.

## Usage

Lets take a look at how to use `ScopeProvider` to provide `RootScopeHolder` and react to scope
changes with `ScopeBuilder`

1. Create instance of `RootScopeHolder` and run app

```dart
void main() {
  final rootScopeHolder = RootScopeHolder();
  rootScopeHolder.create();
  runApp(App(scopeHolder: rootScopeHolder));
}
```

2. Use `ScopeProvider` to provide `RootScopeContainer`

```dart
class App extends StatelessWidget {
  final RootScopeHolder scopeHolder;

  const App({required this.scopeHolder, super.key});

  @override
  Widget build(BuildContext context) {
    return ScopeProvider<RootScopeContainer>(
      holder: scopeHolder,
      child: MaterialApp(
        title: 'YxScopedFlutter Demo',
        home: const HomePage(),
      ),
    );
  }
}
```

3. Use `ScopeBuilder` to react to scope changes for build widget

```dart
// HomePage widget
//...
Widget build() =>
    ScopeBuilder<RootScopeContainer>.withPlaceholder(
      builder: (context, rootScope) => SomeWidget(rootScope),
      placeholder: const SizedBox.shrink(),
    );
// ...
```

## More details

Read full introduction to the library in [the documentation](doc/introduction.md).
