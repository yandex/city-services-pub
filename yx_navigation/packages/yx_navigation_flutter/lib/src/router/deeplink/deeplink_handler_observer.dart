import 'package:meta/meta.dart';
import 'package:yx_navigation/yx_navigation.dart';

/// {@template deeplink_handler_observer}
/// An interface for observing the behavior of DeeplinkHandler instances.
/// {@endtemplate}
@experimental
abstract class DeeplinkHandlerObserver {
  /// {@macro deeplink_handler_observer}
  const DeeplinkHandlerObserver();

  /// Called when a deeplink is received and processing starts.
  @mustCallSuper
  void onDeeplinkReceived({
    required Uri uri,
    required RouteNode currentState,
  }) {}

  /// Called when a deeplink results in navigation.
  @mustCallSuper
  void onDeeplinkNavigate({
    required Uri uri,
    required RouteNode currentState,
    required RouteNode targetState,
  }) {}

  /// Called when a deeplink is handled without navigation.
  @mustCallSuper
  void onDeeplinkHandled({
    required Uri uri,
    required RouteNode currentState,
  }) {}

  /// Called when a deeplink is not handled by the handler.
  @mustCallSuper
  void onDeeplinkSkipped({
    required Uri uri,
    required RouteNode currentState,
  }) {}

  /// Called when an error occurs during deeplink handling.
  @mustCallSuper
  void onDeeplinkError({
    required Uri uri,
    required RouteNode currentState,
    required Object error,
    required StackTrace stackTrace,
  }) {}
}
