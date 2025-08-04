import 'package:flutter/widgets.dart';
import 'package:yx_state/yx_state.dart';

import 'state_consumer.dart';
import 'state_listener.dart';
import 'state_selector.dart';
import 'typedefs.dart';

/// A widget that builds itself based on the latest snapshot of interaction with a [StateReadable].
///
/// [StateBuilder] automatically rebuilds whenever the state from its [stateReadable] changes.
/// It's used for UI components that need to reflect the current state in their presentation.
///
/// The [builder] function is called whenever the state changes and the optional [buildWhen]
/// condition returns true.
///
/// {@tool snippet}
/// This example shows how to use [StateBuilder] to display a counter:
///
/// ```dart
/// class CounterWidget extends StatelessWidget {
///   final CounterReadable counterReadable;
///
///   const CounterWidget({
///     required this.counterReadable,
///     super.key,
///   });
///
///   @override
///   Widget build(BuildContext context) => StateBuilder<int>(
///     stateReadable: counterReadable,
///     buildWhen: (previous, current) => previous != current, // Rebuild only when the value changes
///     builder: (context, count, _) => Text(
///       'Count: $count',
///       style: TextStyle(fontSize: 24),
///     ),
///   );
/// }
///
/// class CounterReadable implements StateReadable<int> {
///   final StreamController<int> _controller = StreamController<int>.broadcast();
///   int _count = 0;
///
///   @override
///   int get state => _count;
///
///   @override
///   Stream<int> get stream => _controller.stream;
///
///   void increment() {
///     _count++;
///     _controller.add(_count);
///   }
///
///   Future<void> dispose() => _controller.close();
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
/// * [StateListener], which performs side effects in response to state changes without rebuilding.
/// * [StateConsumer], which combines both rebuilding and side effects.
/// * [StateSelector], which rebuilds only when a specific part of the state changes.
class StateBuilder<S> extends StatefulWidget {
  /// Creates a new [StateBuilder].
  ///
  /// The [stateReadable] provides the state that this widget will respond to.
  /// The [builder] creates a widget subtree based on the current state.
  /// The optional [buildWhen] determines when the [builder] should rebuild.
  const StateBuilder({
    required this.stateReadable,
    required this.builder,
    this.buildWhen,
    this.child,
    super.key,
  });

  /// The source of the state.
  ///
  /// This state readable object provides both the current state and a stream of state updates.
  /// The [builder] will be called whenever this source emits a new state.
  final StateReadable<S> stateReadable;

  /// The builder that builds a widget based on the current state.
  ///
  /// This function is called with the [BuildContext], the current state, and
  /// an optional [child] widget whenever the state changes and [buildWhen] returns true.
  /// The [child] parameter can be used for optimization by passing widgets that
  /// don't depend on the state.
  final StateWidgetBuilder<S> builder;

  /// Optional condition to determine when the [builder] should rebuild.
  ///
  /// If null, the builder will rebuild on every state change.
  /// If provided, it will be called with the previous and current state,
  /// and only if it returns true will [builder] be called.
  final StateBuilderCondition<S>? buildWhen;

  /// The child of the [StateBuilder].
  ///
  /// If provided, the [builder] will be called with this child as an argument.
  /// This is useful for optimizing rebuilds when part of the widget subtree
  /// doesn't depend on the state.
  final Widget? child;

  @override
  State<StateBuilder<S>> createState() => _StateBuilderState<S>();
}

class _StateBuilderState<S> extends State<StateBuilder<S>> {
  late S _state;

  @override
  void initState() {
    super.initState();
    _state = widget.stateReadable.state;
  }

  @override
  void didUpdateWidget(StateBuilder<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateReadable != widget.stateReadable) {
      _state = widget.stateReadable.state;
    }
  }

  @override
  Widget build(BuildContext context) => StateListener<S>(
        stateReadable: widget.stateReadable,
        listenWhen: widget.buildWhen,
        listener: (context, state) => setState(() => _state = state),
        child: widget.builder(context, _state, widget.child),
      );
}
