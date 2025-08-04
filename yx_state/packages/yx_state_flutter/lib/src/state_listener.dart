import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:yx_state/yx_state.dart';

import 'state_builder.dart';
import 'state_consumer.dart';
import 'state_selector.dart';
import 'typedefs.dart';

/// A widget that listens to a [StateReadable] and calls a listener when the state changes.
///
/// [StateListener] is used for performing side effects in response to state changes
/// such as showing dialogs, navigating to another screen, or logging events. It does not rebuild
/// its child when the state changes.
///
/// The [listener] function is called whenever the state changes and the optional [listenWhen]
/// condition returns true.
///
/// {@tool snippet}
/// This example shows how to use [StateListener] to log state changes and perform navigation:
///
/// ```dart
/// class CounterWidget extends StatelessWidget {
///   final CounterReadable counterReadable;
///   final NavigatorState navigator;
///
///   const CounterWidget({
///     required this.counterReadable,
///     required this.navigator,
///     super.key,
///   });
///
///   @override
///   Widget build(BuildContext context) => StateListener<int>(
///     stateReadable: counterReadable,
///     listenWhen: (previous, current) => current > 5, // Only listen when counter exceeds 5
///     listener: (context, count) {
///       // Log the current count
///       debugPrint('Counter reached milestone: $count');
///
///       // Navigate to a different screen when count reaches 10
///       if (count >= 10) {
///         navigator.pushNamed('/milestone-reached');
///       }
///     },
///     child: const SizedBox(), // A simple placeholder widget
///   );
/// }
///
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
/// * [StateBuilder], which rebuilds when the state changes instead of performing side effects.
/// * [StateConsumer], which combines both rebuilding and side effects.
/// * [StateSelector], which rebuilds only when a specific part of the state changes.
class StateListener<S> extends StatefulWidget {
  /// Creates a new [StateListener].
  ///
  /// The [stateReadable], [listener], and [child] parameters must not be null.
  const StateListener({
    required this.stateReadable,
    required this.listener,
    required this.child,
    this.listenWhen,
    super.key,
  });

  /// The source of the state.
  ///
  /// This state readable object provides both the current state and a stream of state updates.
  /// The [listener] will be called whenever this source emits a new state.
  final StateReadable<S> stateReadable;

  /// The function that is called when the state changes.
  ///
  /// This function is called with the [BuildContext] and the current state
  /// whenever the state changes and [listenWhen] returns true.
  /// Use this for performing side effects like showing dialogs or navigating.
  final StateWidgetListener<S> listener;

  /// The widget below this widget in the tree.
  ///
  /// This widget and its descendants will not rebuild when the state changes.
  /// For a widget that rebuilds with state changes, use [StateBuilder].
  final Widget child;

  /// Optional condition to determine when to call [listener].
  ///
  /// If null, the listener will be called on every state change.
  /// If provided, it will be called with the previous and current state,
  /// and only if it returns true will [listener] be called.
  final StateListenerCondition<S>? listenWhen;

  @override
  State<StateListener<S>> createState() => _StateListenerState<S>();
}

/// The state for the [StateListener] widget.
class _StateListenerState<S> extends State<StateListener<S>> {
  StreamSubscription<S>? _subscription;
  late S _previousState;
  late StateReadable<S> _currentStateReadable;

  @override
  void initState() {
    super.initState();
    _currentStateReadable = widget.stateReadable;
    _previousState = _currentStateReadable.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(StateListener<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stateReadable = widget.stateReadable;
    if (oldWidget.stateReadable != stateReadable) {
      _unsubscribe();
      _currentStateReadable = stateReadable;
      _previousState = _currentStateReadable.state;
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = _currentStateReadable.stream.listen((state) {
      if (!mounted) {
        return;
      }

      if (widget.listenWhen?.call(_previousState, state) ?? true) {
        widget.listener(context, state);
      }

      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
