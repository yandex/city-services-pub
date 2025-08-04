import 'package:flutter/widgets.dart';
import 'package:yx_state/yx_state.dart';

import 'state_builder.dart';
import 'state_consumer.dart';
import 'state_listener.dart';
import 'typedefs.dart';

/// A widget that builds itself based on a part of the state from a [StateReadable].
///
/// [StateSelector] allows you to optimize rebuilds by only rebuilding when a specific
/// part of the state changes, selected by the [selector] function.
///
/// {@tool snippet}
/// This example shows how to use [StateSelector] to only rebuild when a specific
/// property of the state changes:
///
/// ```dart
/// class UserForm extends StatelessWidget {
///   final UserController userController;
///
///   const UserForm({
///     required this.userController,
///     super.key,
///   });
///
///   @override
///   Widget build(BuildContext context) => StateSelector<UserState, bool>(
///     stateReadable: userController,
///     selector: (state) => state.isLoading,
///     builder: (context, isLoading, _) => isLoading
///         ? const CircularProgressIndicator()
///         : const Text('User loaded'),
///   );
/// }
///
/// // A state readable implementation for user
/// class UserController implements StateReadable<UserState> {
///   // Implementation details...
///
///   @override
///   UserState get state => const UserState(); // Example implementation
///
///   @override
///   Stream<UserState> get stream => Stream.empty(); // Example implementation
/// }
///
/// // Assume we have a complex state with multiple properties
/// class UserState {
///   final String name;
///   final bool isLoading;
///   final List<String> permissions;
///
///   const UserState({
///     this.name = '',
///     this.isLoading = false,
///     this.permissions = const <String>[],
///   });
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
/// * [StateBuilder], which rebuilds the UI when the entire state changes.
/// * [StateListener], which performs side effects in response to state changes.
/// * [StateConsumer], which combines both rebuilding and side effects.
class StateSelector<S, U> extends StatefulWidget {
  /// Creates a new [StateSelector].
  const StateSelector({
    required this.stateReadable,
    required this.selector,
    required this.builder,
    this.child,
    super.key,
  });

  /// The source of the state.
  final StateReadable<S> stateReadable;

  /// The function that extracts a value from the state.
  ///
  /// This function is used to select a specific part of the state to watch for changes.
  /// The widget will only rebuild when the selected value changes.
  final StateWidgetSelector<S, U> selector;

  /// The builder that builds a widget based on the selected value.
  ///
  /// This function is called with the selected value whenever it changes.
  final StateWidgetBuilder<U> builder;

  /// The child of the widget.
  ///
  /// If provided, the [builder] will be called with this child as an argument.
  /// This is useful for optimizing rebuilds when part of the widget subtree
  /// doesn't depend on the selected value.
  final Widget? child;

  @override
  State<StateSelector<S, U>> createState() => _StateSelectorState<S, U>();
}

class _StateSelectorState<S, U> extends State<StateSelector<S, U>> {
  late StateReadable<S> _currentStateReadable;
  late U _selectedValue;

  @override
  void initState() {
    super.initState();
    _currentStateReadable = widget.stateReadable;
    _selectedValue = widget.selector(_currentStateReadable.state);
  }

  @override
  void didUpdateWidget(StateSelector<S, U> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateReadable != widget.stateReadable) {
      _currentStateReadable = widget.stateReadable;
      _selectedValue = widget.selector(_currentStateReadable.state);
    } else if (oldWidget.selector != widget.selector) {
      _selectedValue = widget.selector(_currentStateReadable.state);
    }
  }

  @override
  Widget build(BuildContext context) => StateListener<S>(
        stateReadable: _currentStateReadable,
        listener: (context, state) {
          final newValue = widget.selector(state);

          if (newValue != _selectedValue) {
            setState(() => _selectedValue = newValue);
          }
        },
        child: widget.builder(context, _selectedValue, widget.child),
      );
}
