import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';

import 'deeplink/deeplink_handler_observer.dart';

/// {@template route_information_parser_fallback_builder}
/// Produces a fallback [RouteNode] when URI parsing fails.
///
/// Used by [YxRouteInformationParser] to recover from malformed or
/// unrecognized URIs by returning a safe default state.
/// {@endtemplate}
abstract interface class RouteInformationParserFallbackBuilder {
  /// Returns the fallback [RouteNode] to adopt when parsing fails.
  ///
  /// [serializationError] is the error thrown by the serializer, or `null`
  /// when a deeplink handler declined to produce a node.
  Future<RouteNode> buildFallback({
    required RouteNodeStateManager stateManager,
    required RouteInformation routeInformation,
    Object? serializationError,
  });
}

/// {@template route_information_parser_fallback_builder_impl}
/// Default [RouteInformationParserFallbackBuilder] that returns the current
/// state of the [RouteNodeStateManager].
/// {@endtemplate}
class RouteInformationParserFallbackBuilderImpl
    implements RouteInformationParserFallbackBuilder {
  /// {@macro route_information_parser_fallback_builder_impl}
  const RouteInformationParserFallbackBuilderImpl();

  @override
  Future<RouteNode> buildFallback({
    required RouteNodeStateManager stateManager,
    required RouteInformation routeInformation,
    Object? serializationError,
  }) =>
      SynchronousFuture(
        stateManager.state,
      );
}

/// {@template yx_route_information_parser}
/// [RouteInformationParser] that converts platform [RouteInformation] into a
/// [RouteNode].
///
/// Parsing runs an optional [DeeplinkHandler] first and falls back to the
/// configured [PlatformStateSerialization]. When both fail, a
/// [RouteInformationParserFallbackBuilder] produces a recovery node.
/// {@endtemplate}
base class YxRouteInformationParser extends RouteInformationParser<RouteNode> {
  final RouteNodeStateManager _stateManager;
  final PlatformStateSerialization _serialization;
  final RouteInformationParserFallbackBuilder _fallbackBuilder;
  final DeeplinkHandler? _deeplinkHandler;
  final DeeplinkHandlerObserver? _deeplinkHandlerObserver;

  /// Creates a [YxRouteInformationParser].
  ///
  /// {@macro yx_route_information_parser}
  const YxRouteInformationParser({
    required RouteNodeStateManager stateManager,
    required PlatformStateSerialization serialization,
    required RouteInformationParserFallbackBuilder fallbackBuilder,
    DeeplinkHandler? deeplinkHandler,
    DeeplinkHandlerObserver? deeplinkHandlerObserver,
  })  : _stateManager = stateManager,
        _serialization = serialization,
        _fallbackBuilder = fallbackBuilder,
        _deeplinkHandler = deeplinkHandler,
        _deeplinkHandlerObserver = deeplinkHandlerObserver;

  @override
  Future<RouteNode> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    try {
      final uri = routeInformation.uri;

      final deeplinkNode = _tryHandleDeeplink(uri);
      if (deeplinkNode != null) {
        return SynchronousFuture(deeplinkNode);
      }

      final node = _serialization.parse(uri);

      return SynchronousFuture(node);
    } on Object catch (error) {
      return _fallbackBuilder.buildFallback(
        stateManager: _stateManager,
        routeInformation: routeInformation,
        serializationError: error,
      );
    }
  }

  RouteNode? _tryHandleDeeplink(Uri uri) {
    if (_deeplinkHandler == null) {
      return null;
    }

    final currentState = _stateManager.state;
    _deeplinkHandlerObserver?.onDeeplinkReceived(
      uri: uri,
      currentState: currentState,
    );

    try {
      final result = _deeplinkHandler?.handle(uri, currentState);

      switch (result) {
        case DeeplinkHandlerNavigateResult(:final node):
          _deeplinkHandlerObserver?.onDeeplinkNavigate(
            uri: uri,
            currentState: currentState,
            targetState: node,
          );
          return node;

        case DeeplinkHandlerHandledResult():
          _deeplinkHandlerObserver?.onDeeplinkHandled(
            uri: uri,
            currentState: currentState,
          );
          return currentState;

        case null:
          _deeplinkHandlerObserver?.onDeeplinkSkipped(
            uri: uri,
            currentState: currentState,
          );
          return null;
      }
    } on Object catch (error, stackTrace) {
      _deeplinkHandlerObserver?.onDeeplinkError(
        uri: uri,
        currentState: currentState,
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  RouteInformation? restoreRouteInformation(RouteNode configuration) {
    try {
      final uri = _serialization.convert(configuration);
      return RouteInformation(uri: uri);
    } finally {}
  }
}
