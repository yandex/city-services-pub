import 'package:yx_navigation/yx_navigation.dart';

class MockDeeplinkHandler implements DeeplinkHandler {
  DeeplinkHandlerResult? Function(Uri uri, RouteNode currentState)? onHandle;

  final List<(Uri, RouteNode)> handleCalls = [];

  MockDeeplinkHandler();

  @override
  DeeplinkHandlerResult? handle(Uri uri, RouteNode currentState) {
    handleCalls.add((uri, currentState));
    return onHandle?.call(uri, currentState);
  }

  void reset() {
    handleCalls.clear();
    onHandle = null;
  }
}
