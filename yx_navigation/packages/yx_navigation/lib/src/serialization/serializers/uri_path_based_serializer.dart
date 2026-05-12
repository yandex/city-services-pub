import 'package:meta/meta.dart';

import '../../base/route_node.dart';
import '../route_node_serialization_tools.dart';
import 'uri_fragment_based_serializer.dart';

/// Path-based serializer for navigation state.
///
/// Serializes [RouteNode] tree to URL path (without #) using base64 encoding.
///
/// Example: `/('cnQ':('aWQ':'cm9vdA'))`
///
/// This is useful for scenarios where third parties ignore the hash (#)
/// in redirect URLs, such as OAuth callbacks or Telegram login redirects.
///
/// See also:
/// - [UriFragmentBasedSerializer] for fragment-based serialization
@internal
abstract class UriPathBasedSerializer {
  static ImmutableRouteNode fromUri(Uri uri) {
    // Remove leading slash from path
    var pathContent = uri.path;
    if (pathContent.startsWith('/')) {
      pathContent = pathContent.substring(1);
    }
    final jsonMap = UriFragmentBasedSerializer.fromUriString(pathContent);
    return RouteNodeSerializationTools.fromJson(jsonMap);
  }

  static Uri toUri(RouteNode node) {
    final map = RouteNodeSerializationTools.toJson(node);
    final encodedString = UriFragmentBasedSerializer.toUriString(map);
    return Uri(path: '/$encodedString');
  }
}
