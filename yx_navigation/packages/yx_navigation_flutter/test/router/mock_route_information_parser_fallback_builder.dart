import 'package:flutter/widgets.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/router/yx_route_information_parser.dart';

class MockRouteInformationParserFallbackBuilder
    implements RouteInformationParserFallbackBuilder {
  Future<RouteNode> Function({
    required RouteNodeStateManager stateManager,
    required RouteInformation routeInformation,
    Object? serializationError,
  })? onBuildFallback;

  final List<
      ({
        RouteNodeStateManager stateManager,
        RouteInformation routeInformation,
        Object? serializationError,
      })> buildFallbackCalls = [];

  MockRouteInformationParserFallbackBuilder();

  @override
  Future<RouteNode> buildFallback({
    required RouteNodeStateManager stateManager,
    required RouteInformation routeInformation,
    Object? serializationError,
  }) {
    buildFallbackCalls.add((
      stateManager: stateManager,
      routeInformation: routeInformation,
      serializationError: serializationError,
    ));
    final node = onBuildFallback?.call(
      stateManager: stateManager,
      routeInformation: routeInformation,
      serializationError: serializationError,
    );
    if (node == null) {
      throw UnimplementedError('onBuildFallback not configured');
    }
    return node;
  }

  void reset() {
    buildFallbackCalls.clear();
    onBuildFallback = null;
  }
}
