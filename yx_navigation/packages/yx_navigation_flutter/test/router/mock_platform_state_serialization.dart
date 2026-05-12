import 'package:yx_navigation/yx_navigation.dart';

class MockPlatformStateSerialization implements PlatformStateSerialization {
  RouteNode Function(Uri uri)? onParse;
  Uri Function(RouteNode node)? onConvert;

  final List<Uri> parseCalls = [];
  final List<RouteNode> convertCalls = [];

  MockPlatformStateSerialization();

  @override
  RouteNode parse(Uri uri) {
    parseCalls.add(uri);
    final node = onParse?.call(uri);
    if (node == null) {
      throw UnimplementedError('onParse not configured');
    }
    return node;
  }

  @override
  Uri convert(RouteNode node) {
    convertCalls.add(node);
    final uri = onConvert?.call(node);
    if (uri == null) {
      throw UnimplementedError('onConvert not configured');
    }
    return uri;
  }

  void reset() {
    parseCalls.clear();
    convertCalls.clear();
    onParse = null;
    onConvert = null;
  }
}
