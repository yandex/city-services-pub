import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../base/route.dart';
import '../../base/route_node.dart';
import 'squid_fragment_based_serializer.dart';

/// {@template squid_path_based_serializer}
/// Path-based serializer for navigation state.
///
/// Serializes [RouteNode] tree to URL path (without #).
///
/// Example: `/root/.child1/..child2`
///
/// This is useful for scenarios where third parties ignore the hash (#)
/// in redirect URLs, such as OAuth callbacks or Telegram login redirects.
///
/// See also:
/// - [SquidFragmentBasedSerializer] for fragment-based serialization
/// {@endtemplate}
abstract class SquidPathBasedSerializer {
  @visibleForTesting
  static const prefix = SquidFragmentBasedSerializer.prefix;

  /// Parses [uri]'s path back into a [RouteNode] tree.
  ///
  /// Throws a [FormatException] if the path is malformed.
  static RouteNode fromUri(Uri uri) {
    final List<_NodeDataSegment> segments = _toSegments(uri);

    final rootNode = _fromSegments(segments).firstOrNull;
    if (rootNode == null) {
      throw const FormatException('No nodes detected');
    }
    return rootNode.toImmutable();
  }

  /// Encodes [node] as a [Uri] whose path describes the tree.
  static Uri toUri(RouteNode node) {
    final segments = SquidFragmentBasedSerializer.encodeNode(node, depth: 0);

    return Uri(
      path: '/${segments.where((s) => s.isNotEmpty).join('/')}',
    );
  }

  static List<RouteNode> _fromSegments(
    List<_NodeDataSegment> segments, {
    int depth = 0,
  }) {
    final chunks = segments
        .splitBefore(
          (element) => element.depth == depth,
        )
        .toList();

    if (depth == 0 && chunks.isEmpty) {
      throw const FormatException('No nodes detected');
    }

    if (depth == 0 && chunks.length > 1) {
      throw const FormatException('Multiple root nodes detected');
    }

    final nodes = chunks.map((chunk) {
      final chunkRoot = chunk.firstOrNull;
      if (chunkRoot == null) {
        throw FormatException(
          'Empty chunk detected when processing segments: $segments',
        );
      }

      return RouteNode.mutable(
        route: chunkRoot.route,
        arguments: chunkRoot.args,
        extra: const {},
        children: _fromSegments(
          chunk.sublist(1),
          depth: depth + 1,
        ),
      );
    });

    return nodes.toList();
  }

  static String _returnReservedChars(String string) {
    final buffer = StringBuffer();
    for (var i = 0; i < string.length; i++) {
      final char = string[i];
      buffer.write(SquidFragmentBasedSerializer.pcharToReserved[char] ?? char);
    }
    return buffer.toString();
  }

  static List<_NodeDataSegment> _toSegments(Uri uri) {
    // Use pathSegments which returns already decoded segments.
    // Unlike uri.path which may contain encoded characters like %3F for '?',
    // pathSegments returns decoded values.
    final segments = uri.pathSegments
        .whereNot(
          (test) => test.isEmpty,
        )
        .toList();
    final List<_NodeDataSegment> nodes = [];
    final routeStartPattern = RegExp('[^$prefix]');
    for (final segment in segments) {
      final parts =
          segment.split(SquidFragmentBasedSerializer.argsAndIdSeparator);
      if (parts.length > 2) {
        throw FormatException(
          'Part of URI contains multiple separators. '
          'The violating segment is: $segment',
        );
      }
      final routeNameWithPrefix = parts.firstOrNull;
      if (routeNameWithPrefix == null) {
        throw FormatException(
          'Part of URI contains no route name. '
          'The violating segment is: $segment',
        );
      }
      int depth = routeNameWithPrefix.indexOf(routeStartPattern);
      if (depth == -1) {
        depth = 0;
      }
      final encodedRouteName = routeNameWithPrefix.substring(depth);
      final encodedRouteNameWithReservedChars =
          _returnReservedChars(encodedRouteName);
      final decodedRouteName = Uri.decodeComponent(
        encodedRouteNameWithReservedChars,
      );
      final route = YxRoute(id: decodedRouteName);
      final Map<String, String> args;
      final argsPart = parts.lastOrNull;
      if (argsPart == null) {
        args = const {};
      } else {
        final argsUri = Uri.parse(argsPart);
        final argsEncoded = argsUri.queryParameters;
        args = argsEncoded.map(
          (key, value) => MapEntry(
            _returnReservedChars(key),
            _returnReservedChars(value),
          ),
        );
      }
      nodes.add(_NodeDataSegment(depth: depth, route: route, args: args));
    }

    return nodes;
  }
}

final class _NodeDataSegment {
  final Map<String, String> args;
  final int depth;
  final YxRoute route;

  const _NodeDataSegment({
    required this.depth,
    required this.route,
    required this.args,
  });
}
