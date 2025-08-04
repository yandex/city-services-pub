import 'package:flutter/widgets.dart';
import 'package:yx_state/yx_state.dart';

import 'state_builder.dart';
import 'state_listener.dart';
import 'state_selector.dart';
import 'typedefs.dart';

/// A widget that combines [StateBuilder] and [StateListener].
///
/// [StateConsumer] is useful when you need a widget that both rebuilds UI and
/// performs side effects (like navigation, showing dialogs) in response to state changes.
///
/// {@tool snippet}
/// This example shows how to use [StateConsumer] for a login form:
///
/// ```dart
/// // Using StateConsumer in a widget
/// class LoginScreen extends StatelessWidget {
///   final LoginController loginController;
///
///   const LoginScreen({
///     required this.loginController,
///     super.key,
///   });
///
///   @override
///   Widget build(BuildContext context) => Scaffold(
///     appBar: AppBar(title: Text('Login')),
///     body: StateConsumer<LoginState>(
///       stateReadable: loginController,
///       listener: (context, state) {
///         if (state.status == LoginStatus.success) {
///           Navigator.of(context).pushReplacementNamed('/home');
///         } else if (state.status == LoginStatus.error) {
///           ScaffoldMessenger.of(context).showSnackBar(
///             SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
///           );
///         }
///       },
///       builder: (context, state, _) => LoginForm(
///         isLoading: state.status == LoginStatus.loading,
///       ),
///     ),
///   );
/// }
///
/// // A simple login form widget
/// class LoginForm extends StatelessWidget {
///   final bool isLoading;
///
///   const LoginForm({
///     required this.isLoading,
///     super.key,
///   });
///
///   @override
///   Widget build(BuildContext context) => Center(
///     child: isLoading
///         ? const CircularProgressIndicator()
///         : const Text('Login Form'),
///   );
/// }
///
/// // Example state and state readable
/// enum LoginStatus { initial, loading, success, error }
///
/// class LoginState {
///   final LoginStatus status;
///   final String? errorMessage;
///
///   const LoginState({
///     this.status = LoginStatus.initial,
///     this.errorMessage,
///   });
/// }
///
/// // A state readable implementation for login
/// class LoginController implements StateReadable<LoginState> {
///   // Implementation details...
///
///   @override
///   LoginState get state => const LoginState(); // Example implementation
///
///   @override
///   Stream<LoginState> get stream => Stream.empty(); // Example implementation
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
/// * [StateBuilder], which only rebuilds the UI in response to state changes.
/// * [StateListener], which only performs side effects in response to state changes.
/// * [StateSelector], which rebuilds only when a specific part of the state changes.
class StateConsumer<S> extends StatelessWidget {
  /// Creates a new [StateConsumer].
  const StateConsumer({
    required this.stateReadable,
    required this.builder,
    required this.listener,
    this.buildWhen,
    this.listenWhen,
    this.child,
    super.key,
  });

  /// The source of the state.
  final StateReadable<S> stateReadable;

  /// The builder that builds a widget based on the current state.
  final StateWidgetBuilder<S> builder;

  /// The function that is called when the state changes.
  final StateWidgetListener<S> listener;

  /// Optional condition to determine when the [builder] should rebuild.
  /// If null, the builder will rebuild on every state change.
  final StateBuilderCondition<S>? buildWhen;

  /// Optional condition to determine when to call [listener].
  /// If null, the listener will be called on every state change.
  final StateListenerCondition<S>? listenWhen;

  /// The child of the [StateConsumer].
  ///
  /// If provided, the [builder] will be called with this child as an argument.
  /// This is useful for optimizing rebuilds when part of the widget subtree
  /// doesn't depend on the state.
  final Widget? child;

  @override
  Widget build(BuildContext context) => StateBuilder<S>(
        stateReadable: stateReadable,
        builder: builder,
        buildWhen: (previous, current) {
          if (listenWhen?.call(previous, current) ?? true) {
            listener(context, current);
          }
          return buildWhen?.call(previous, current) ?? true;
        },
        child: child,
      );
}
