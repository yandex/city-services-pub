import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../base/route.dart';
import '../../base/route_node.dart';

/// {@template squid_fragment_based_serializer}
/// Fragment-based serializer for navigation state.
///
/// Serializes [RouteNode] tree to URL fragment (after #).
///
/// Example: `#/root/.child1/..child2`
///
/// See also:
/// - [SquidPathBasedSerializer] for path-based serialization
/// {@endtemplate}
abstract class SquidFragmentBasedSerializer {
  /// Separator between route id and arguments in URL segment.
  @internal
  static const argsAndIdSeparator = r'$';

  /// Prefix used to indicate depth level in URL segment.
  @internal
  static const prefix = '.';

  /// Mapping from pchar (URL-safe) to reserved characters.
  @internal
  static final Map<String, String> pcharToReserved = reservedToPchar.map(
    (key, value) => MapEntry(value, key),
  );

  /// Mapping from reserved characters to pchar (URL-safe) equivalents.
  @internal
  static const Map<String, String> reservedToPchar = {
    '/': '(',
    '.': '\'',
  };

  /// Encodes a [RouteNode] tree into URL segments.
  @internal
  static List<String> encodeNode(
    RouteNode node, {
    required int depth,
  }) {
    final segments = <String>[];
    final prefixString = prefix * depth;
    final String name;
    final idWithoutReservedChars = _removeReservedChars(node.route.id);
    final id = Uri.encodeComponent(idWithoutReservedChars);

    if (node.arguments.isEmpty) {
      name = id;
    } else {
      var argsEntries = node.arguments.entries.toList(growable: false);
      argsEntries = argsEntries.sortedBy<String>((arg) => arg.key);
      final argsWithoutReservedChars = argsEntries.map(
        (entry) => MapEntry(
          _removeReservedChars(entry.key),
          _removeReservedChars(entry.value),
        ),
      );
      final argsMapWithoutReservedChars =
          Map.fromEntries(argsWithoutReservedChars);
      final args = Uri(queryParameters: argsMapWithoutReservedChars);
      final argsString = args.toString();
      name = argsString.isEmpty ? id : '$id$argsAndIdSeparator$argsString';
    }

    segments.add('$prefixString$name');

    for (final child in node.children) {
      segments.addAll(encodeNode(
        child,
        depth: depth + 1,
      ));
    }

    return segments;
  }

  /// Parses [uri]'s fragment back into a [RouteNode] tree.
  ///
  /// Throws a [FormatException] if the fragment is malformed.
  static RouteNode fromUri(Uri uri) {
    final List<_NodeDataSegment> segments = _toSegments(uri);

    final rootNode = _fromSegments(segments).firstOrNull;
    if (rootNode == null) {
      throw const FormatException('No nodes detected');
    }
    return rootNode.toImmutable();
  }

  /// Encodes [node] as a [Uri] whose fragment describes the tree.
  static Uri toUri(RouteNode node) {
    final segments = encodeNode(node, depth: 0);

    return Uri(
      fragment: '/${segments.where((s) => s.isNotEmpty).join('/')}',
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

  static String _removeReservedChars(String string) {
    final buffer = StringBuffer();
    for (var i = 0; i < string.length; i++) {
      final char = string[i];
      buffer.write(reservedToPchar[char] ?? char);
    }
    return buffer.toString();
  }

  static String _returnReservedChars(String string) {
    final buffer = StringBuffer();
    for (var i = 0; i < string.length; i++) {
      final char = string[i];
      buffer.write(pcharToReserved[char] ?? char);
    }
    return buffer.toString();
  }

  static List<_NodeDataSegment> _toSegments(
    Uri uri,
  ) {
    final segments = uri.fragment
        .split('/')
        .whereNot(
          (test) => test.isEmpty,
        )
        .toList();
    final List<_NodeDataSegment> nodes = [];
    final routeStartPattern = RegExp('[^$prefix]');
    for (final segment in segments) {
      final parts = segment.split(argsAndIdSeparator);
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

/// Deprecated: Use [SquidFragmentBasedSerializer] instead.
@Deprecated('Use SquidFragmentBasedSerializer instead')
typedef SquidSerializer = SquidFragmentBasedSerializer;
