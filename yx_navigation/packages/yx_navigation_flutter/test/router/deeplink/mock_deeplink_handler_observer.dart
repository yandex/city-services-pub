import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/router/deeplink/deeplink_handler_observer.dart';

class MockDeeplinkHandlerObserver implements DeeplinkHandlerObserver {
  final List<(Uri, RouteNode)> receivedCalls = [];
  final List<(Uri, RouteNode, RouteNode)> navigateCalls = [];
  final List<(Uri, RouteNode)> handledCalls = [];
  final List<(Uri, RouteNode)> skippedCalls = [];
  final List<(Uri, RouteNode, Object, StackTrace)> errorCalls = [];

  MockDeeplinkHandlerObserver();

  @override
  void onDeeplinkReceived({
    required Uri uri,
    required RouteNode currentState,
  }) {
    receivedCalls.add((uri, currentState));
  }

  @override
  void onDeeplinkNavigate({
    required Uri uri,
    required RouteNode currentState,
    required RouteNode targetState,
  }) {
    navigateCalls.add((uri, currentState, targetState));
  }

  @override
  void onDeeplinkHandled({
    required Uri uri,
    required RouteNode currentState,
  }) {
    handledCalls.add((uri, currentState));
  }

  @override
  void onDeeplinkSkipped({
    required Uri uri,
    required RouteNode currentState,
  }) {
    skippedCalls.add((uri, currentState));
  }

  @override
  void onDeeplinkError({
    required Uri uri,
    required RouteNode currentState,
    required Object error,
    required StackTrace stackTrace,
  }) {
    errorCalls.add((uri, currentState, error, stackTrace));
  }

  void reset() {
    receivedCalls.clear();
    navigateCalls.clear();
    handledCalls.clear();
    skippedCalls.clear();
    errorCalls.clear();
  }
}
