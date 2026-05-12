import 'dart:convert' as converter;

import 'package:meta/meta.dart';

import '../../base/route_node.dart';
import '../route_node_serialization_tools.dart';

/// Fragment-based serializer for navigation state.
///
/// Serializes [RouteNode] tree to URL fragment (after #) using base64
/// encoding.
///
/// Example: `#('cnQ':('aWQ':'cm9vdA'))`
///
/// See also:
/// - [UriPathBasedSerializer] for path-based serialization
@internal
abstract class UriFragmentBasedSerializer {
  /// Mapping from pchar (URL-safe) to reserved characters.
  static final Map<String, String> pcharToReserved = reservedToPchar.map(
    (key, value) => MapEntry(value, key),
  );

  /// Mapping from reserved characters to pchar (URL-safe) equivalents.
  ///
  /// https://www.ietf.org/rfc/rfc3986.txt
  /// We need to convert a string to a segment, see 3.3
  ///
  /// Each symbol must then become a pchar
  /// Refer to 2.2 for list of symbols eligible
  static const Map<String, String> reservedToPchar = {
    '[': '&',
    ']': r'$',
    '{': '(',
    '}': ')',
    '"': '\'',
  };

  @visibleForTesting
  static String decodeString(String string) => converter.utf8.decode(
        converter.base64Url.decode(
          converter.base64.normalize(string),
        ),
      );

  @visibleForTesting
  static String encodeString(String string) => converter.base64Url
      .encode(converter.utf8.encode(string))
      .replaceAll('=', '');

  static ImmutableRouteNode fromUri(Uri uri) {
    final jsonMap = fromUriString(uri.fragment);
    return RouteNodeSerializationTools.fromJson(jsonMap);
  }

  /// Works in three steps
  ///
  /// 1. Call [replaceAll] to replace each symbol reserved in a Uri RFC
  /// with its decoded equivalent
  /// 2. Call [jsonDecode] to turn the string into a map
  /// 3. Call [recursivelyDecode] to decode each key and value in the map
  static Map<String, Object?> fromUriString(String value) {
    String decodedString = value;

    final buffer = StringBuffer();
    for (var i = 0; i < decodedString.length; i++) {
      final char = decodedString[i];
      buffer.write(pcharToReserved[char] ?? char);
    }
    decodedString = buffer.toString();

    final decodedValue = converter.jsonDecode(decodedString);
    final decodedMap = recursivelyDecode(decodedValue);

    final map = decodedMap as Map<String, Object?>?;

    if (map == null) {
      throw const FormatException('Trying to deserialize a map with no data');
    }

    return map;
  }

  @visibleForTesting
  static Object? recursivelyDecode(Object? value) {
    if (value is String) {
      return decodeString(value);
    } else if (value is Map<String, Object?>) {
      return value.map(
        (key, mapValue) => MapEntry(
          decodeString(key),
          recursivelyDecode(mapValue),
        ),
      );
    } else if (value is List) {
      return value.map((item) => recursivelyDecode(item)).toList();
    }

    return value;
  }

  @visibleForTesting
  static Object? recursivelyEncode(Object? value) {
    if (value is String) {
      return encodeString(value);
    } else if (value is Map<String, Object?>) {
      return value.map(
        (key, mapValue) => MapEntry(
          encodeString(key),
          recursivelyEncode(mapValue),
        ),
      );
    } else if (value is List) {
      return value.map((item) => recursivelyEncode(item)).toList();
    }

    return value;
  }

  static Uri toUri(RouteNode node) {
    final map = RouteNodeSerializationTools.toJson(node);
    final encodedString = toUriString(map);
    return Uri(fragment: encodedString);
  }

  /// Works in three steps
  ///
  /// 1. Call [recursivelyEncode] to encode each key and value in the map
  /// 2. Call [jsonEncode] to turn the map into a string
  /// 3. Call [replaceAll] to replace each symbol reserved in a Uri RFC
  ///  with its encoded equivalent
  static String toUriString(Map<String, Object?> map) {
    final urlEncodedMap = recursivelyEncode(map) as Map<String, Object?>?;
    final encodedString = converter.jsonEncode(urlEncodedMap);

    final buffer = StringBuffer();
    for (var i = 0; i < encodedString.length; i++) {
      final char = encodedString[i];
      buffer.write(reservedToPchar[char] ?? char);
    }

    return buffer.toString();
  }
}

/// Deprecated: Use [UriFragmentBasedSerializer] instead.
@Deprecated('Use UriFragmentBasedSerializer instead')
typedef UriSerializer = UriFragmentBasedSerializer;
