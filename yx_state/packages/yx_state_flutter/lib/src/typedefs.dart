import 'package:flutter/widgets.dart';

/// Builder function that builds a widget based on the current state.
typedef StateWidgetBuilder<S> = Widget Function(
  BuildContext context,
  S state,
  Widget? child,
);

/// Listener function that is called when the state changes.
typedef StateWidgetListener<S> = void Function(BuildContext context, S state);

/// Function that determines when a widget should rebuild.
typedef StateBuilderCondition<S> = bool Function(S previous, S current);

/// Function that determines when a listener should be called.
typedef StateListenerCondition<S> = bool Function(S previous, S current);

/// Function that extracts a value from the state.
typedef StateWidgetSelector<S, T> = T Function(S state);
