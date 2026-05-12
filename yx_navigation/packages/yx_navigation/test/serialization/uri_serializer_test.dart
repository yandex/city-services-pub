import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
// internal type, not exported
import 'package:yx_navigation/src/base/route.dart';
import 'package:yx_navigation/src/base/route_node.dart';
import 'package:yx_navigation/src/serialization/route_node_serialization_tools.dart';
// internal type, not exported
import 'package:yx_navigation/src/serialization/serializers/uri_fragment_based_serializer.dart';

void main() {
  group('UriFragmentBasedSerializer', () {
    group('toUriString', () {
      test('works as expected', () {
        const source = {
          'key': 'value',
          '[]{}":': '&\$()\'',
          'list': [1, 2, 3],
        };
        const encoded =
            r"('a2V5':'dmFsdWU','W117fSI6':'JiQoKSc','bGlzdA':&1,2,3$)";

        expect(
          UriFragmentBasedSerializer.toUriString(source),
          equals(encoded),
        );
      });
    });
    group('fromUriString', () {
      test('works as expected', () {
        const source = {
          'key': 'value',
          '[]{}":': '&\$()\'',
          'list': [1, 2, 3],
        };
        const encoded =
            r"('a2V5':'dmFsdWU','W117fSI6':'JiQoKSc','bGlzdA':&1,2,3$)";

        expect(
          const DeepCollectionEquality().equals(
            source,
            UriFragmentBasedSerializer.fromUriString(encoded),
          ),
          isTrue,
        );
      });
    });

    group('decodeString', () {
      test('round-trips arbitrary UTF-8 chinese input through encode + decode',
          () {
        // Multi-byte UTF-8 + URI-unreserved punctuation per RFC 3986
        // ("-_.!~*'()") verifies that the codec preserves arbitrary input
        // without stripping or escaping characters that some implementations
        // would mistakenly mangle.
        const source = "你好, 世界! -_.!~*'()";

        final encoded = UriFragmentBasedSerializer.encodeString(source);
        // Guard the round-trip: a symmetric bug in both encode/decode
        // (e.g. returning empty string in both directions) would otherwise
        // satisfy `decode(encode(x)) == x` vacuously.
        expect(encoded, isNotEmpty);
        expect(encoded, isNot(equals(source)));
        expect(
          UriFragmentBasedSerializer.decodeString(encoded),
          equals(source),
        );
      });

      test('round-trips arbitrary UTF-8 cyrillic input through encode + decode',
          () {
        // Cyrillic multi-byte UTF-8 + URI-unreserved punctuation per RFC 3986
        // ("-_.!~*'()") — verifies that the codec preserves arbitrary input
        // without stripping or escaping characters that some implementations
        // would mistakenly mangle.
        const source = "Привет, мир! -_.!~*'()";

        final encoded = UriFragmentBasedSerializer.encodeString(source);
        // Guard the round-trip: a symmetric bug in both encode/decode
        // (e.g. returning empty string in both directions) would otherwise
        // satisfy `decode(encode(x)) == x` vacuously.
        expect(encoded, isNotEmpty);
        expect(encoded, isNot(equals(source)));
        expect(
          UriFragmentBasedSerializer.decodeString(encoded),
          equals(source),
        );
      });
    });

    group('encodeString', () {
      test('output contains only URI-safe characters (idempotent under encode)',
          () {
        const allAsciiSymbols =
            ' !"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
        final encoded =
            UriFragmentBasedSerializer.encodeString(allAsciiSymbols);
        // Re-encoding should be a no-op: the output must already be URI-safe.
        expect(encoded, equals(Uri.encodeComponent(encoded)));
      });
      group('invalid URIs are encoded correctly', () {
        void testString(String uriIncompatibleString) {
          final input =
              UriFragmentBasedSerializer.encodeString(uriIncompatibleString);

          final decoded = Uri.decodeComponent(input);
          expect(input, equals(decoded));
        }

        test(
          'URI with space in scheme',
          () => testString('ht tp://example.com'),
        );
        test(
          'URI with invalid characters in domain',
          () => testString(r'https://exa$mple.com'),
        );
        test(
          'URI with space in fragment',
          () => testString('https://example.com/page#frag ment'),
        );
        test(
          'URI with newline character',
          () => testString('https://example.com/some\npath'),
        );
        test(
          'URI with unsupported characters',
          () => testString('https://example.com/page<with>invalid'),
        );
        test(
          'URI with invalid percent encoding',
          () => testString('https://example.com/path%ZZwitherror'),
        );
      });

      test('does not include URI incompatible chars that are in base64', () {
        final source = String.fromCharCodes(
          base64Url.decode(
            'g7Dm1xHckp92nuJ76f/LlC0jmfVz9IM5dAd+xltfnd+gA8HqNc2A1Yl4D8mQU7f10irkEcllwj7fxEghfoBqNSOdhoLgdx6+wGVhFYuPX3ivT6T3kQIaWIqatZxX+uSTXYCtjg==',
          ),
        );

        expect(
          UriFragmentBasedSerializer.encodeString(source),
          equals(
            Uri.encodeComponent(
              UriFragmentBasedSerializer.encodeString(source),
            ),
          ),
        );
      });
    });

    group('toUri', () {
      test('serialized as expected', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'home'),
          arguments: const {
            'user': 'watermelon=good',
          },
          children: [
            RouteNode.fromRoute(
              route: const YxRoute(id: 'level1-1'),
              arguments: const {
                'arg1': 'value1',
                'arg2': 'value2',
              },
              children: [
                RouteNode.fromRoute(
                  route: const YxRoute(id: 'level2'),
                  children: [
                    RouteNode.fromRoute(
                      route: const YxRoute(id: 'level3-1'),
                      children: [
                        RouteNode.fromRoute(
                          route: const YxRoute(id: 'level4-1'),
                        ),
                        RouteNode.fromRoute(
                          route: const YxRoute(id: 'level4-2'),
                        ),
                      ],
                    ),
                    RouteNode.fromRoute(
                      route: const YxRoute(id: 'level3-2'),
                      children: [
                        RouteNode.fromRoute(
                          route: const YxRoute(id: 'level4-1'),
                        ),
                        RouteNode.fromRoute(
                          route: const YxRoute(id: 'level4-2'),
                          children: [
                            RouteNode.fromRoute(
                              route: const YxRoute(id: 'level5'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            RouteNode.fromRoute(
              route: const YxRoute(id: 'level1-2'),
            ),
          ],
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'aG9tZQ'),'YXJncw':('dXNlcg':'d2F0ZXJtZWxvbj1nb29k'),'Yw':&('cnQ':('aWQ':'bGV2ZWwxLTE'),'YXJncw':('YXJnMQ':'dmFsdWUx','YXJnMg':'dmFsdWUy'),'Yw':&('cnQ':('aWQ':'bGV2ZWwy'),'Yw':&('cnQ':('aWQ':'bGV2ZWwzLTE'),'Yw':&('cnQ':('aWQ':'bGV2ZWw0LTE')),('cnQ':('aWQ':'bGV2ZWw0LTI'))$),('cnQ':('aWQ':'bGV2ZWwzLTI'),'Yw':&('cnQ':('aWQ':'bGV2ZWw0LTE')),('cnQ':('aWQ':'bGV2ZWw0LTI'),'Yw':&('cnQ':('aWQ':'bGV2ZWw1'))$)$)$)$),('cnQ':('aWQ':'bGV2ZWwxLTI'))$)''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('reserved symbols are encoded correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'a[]{}"b'),
          arguments: const {
            'key[]{}"': 'value[]{}"',
            'another': r'test&$()' "'",
          },
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'YVtde30iYg'),'YXJncw':('a2V5W117fSI':'dmFsdWVbXXt9Ig','YW5vdGhlcg':'dGVzdCYkKCkn'))''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('empty arguments are handled correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route_without_args'),
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw = r'''#('cnQ':('aWQ':'cm91dGVfd2l0aG91dF9hcmdz'))''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('empty children are handled correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route_without_children'),
          arguments: const {
            'arg1': 'value1',
          },
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'cm91dGVfd2l0aG91dF9jaGlsZHJlbg'),'YXJncw':('YXJnMQ':'dmFsdWUx'))''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('deep nesting is handled correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(
              route: const YxRoute(id: 'level1'),
              children: [
                RouteNode.fromRoute(
                  route: const YxRoute(id: 'level2'),
                  children: [
                    RouteNode.fromRoute(
                      route: const YxRoute(id: 'level3'),
                      children: [
                        RouteNode.fromRoute(
                          route: const YxRoute(id: 'level4'),
                          children: [
                            RouteNode.fromRoute(
                              route: const YxRoute(id: 'level5'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'cm9vdA'),'Yw':&('cnQ':('aWQ':'bGV2ZWwx'),'Yw':&('cnQ':('aWQ':'bGV2ZWwy'),'Yw':&('cnQ':('aWQ':'bGV2ZWwz'),'Yw':&('cnQ':('aWQ':'bGV2ZWw0'),'Yw':&('cnQ':('aWQ':'bGV2ZWw1'))$)$)$)$)$)''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('multiple children at same level are handled correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'root'),
          children: [
            RouteNode.fromRoute(
              route: const YxRoute(id: 'child1'),
            ),
            RouteNode.fromRoute(
              route: const YxRoute(id: 'child2'),
            ),
            RouteNode.fromRoute(
              route: const YxRoute(id: 'child3'),
            ),
          ],
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'cm9vdA'),'Yw':&('cnQ':('aWQ':'Y2hpbGQx')),('cnQ':('aWQ':'Y2hpbGQy')),('cnQ':('aWQ':'Y2hpbGQz'))$)''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('special characters in route id and arguments are handled', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route-with-special-chars_123'),
          arguments: const {
            'key-with-dash': 'value_with_underscore',
            'key.with.dots': 'value/with/slashes',
            'key=equals': 'value&and',
          },
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'cm91dGUtd2l0aC1zcGVjaWFsLWNoYXJzXzEyMw'),'YXJncw':('a2V5LXdpdGgtZGFzaA':'dmFsdWVfd2l0aF91bmRlcnNjb3Jl','a2V5LndpdGguZG90cw':'dmFsdWUvd2l0aC9zbGFzaGVz','a2V5PWVxdWFscw':'dmFsdWUmYW5k'))''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('cyrillic unicode characters are handled correctly', () {
        // Cyrillic route id + Cyrillic key/value + multi-byte emoji —
        // exercises the full UTF-8 round-trip through the URL-safe base64
        // encoder used by the fragment-based serializer.
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route-с-кириллицей'),
          arguments: const {
            'ключ': 'значение',
            'emoji': '🚀🎉',
          },
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'cm91dGUt0YEt0LrQuNGA0LjQu9C70LjRhtC10Lk'),'YXJncw':('0LrQu9GO0Yc':'0LfQvdCw0YfQtdC90LjQtQ','ZW1vamk':'8J-agPCfjok'))''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('chinese unicode characters are handled correctly', () {
        // Non-ASCII route id + non-ASCII key/value + multi-byte emoji
        // exercises the full UTF-8 round-trip through the URL-safe base64
        // encoder used by the fragment-based serializer.
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route-with-中文'),
          arguments: const {
            'key-中文': 'value-中文',
            'emoji': '🚀🎉',
          },
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'cm91dGUtd2l0aC3kuK3mloc'),'YXJncw':('a2V5LeS4reaWhw':'dmFsdWUt5Lit5paH','ZW1vamk':'8J-agPCfjok'))''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });

      test('empty string arguments are handled', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'route'),
          arguments: const {
            'empty': '',
            'nonEmpty': 'value',
          },
        );

        final encoded = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(encoded);
        const encodedRaw =
            r'''#('cnQ':('aWQ':'cm91dGU'),'YXJncw':('ZW1wdHk':'','bm9uRW1wdHk':'dmFsdWU'))''';

        expect(decoded, equals(node));
        expect(encoded.toString(), equals(encodedRaw));
      });
    });

    group('fromJson', () {
      test('throws FormatException when arguments is not a Map', () {
        final json = {
          'rt': {'id': 'test'},
          'args': 'not-a-map', // Invalid: should be a Map
        };

        expect(
          () => RouteNodeSerializationTools.fromJson(json),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('invalid arguments type'),
          )),
        );
      });

      test('throws FormatException when arguments contains non-string values',
          () {
        final json = {
          'rt': {'id': 'test'},
          'args': {
            'key1': 'value1', // Valid string
            'key2': 123, // Invalid: should be String
            'key3': true, // Invalid: should be String
            'key4': ['list'], // Invalid: should be String
          },
        };

        expect(
          () => RouteNodeSerializationTools.fromJson(json),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('invalid argument value type'),
          )),
        );
      });

      test('throws FormatException with correct key name for non-string value',
          () {
        final json = {
          'rt': {'id': 'test'},
          'args': {
            'validKey': 'validValue',
            'invalidKey': 42,
          },
        };

        expect(
          () => RouteNodeSerializationTools.fromJson(json),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('invalid argument value type'),
              contains('invalidKey'),
              contains('int'),
            ),
          )),
        );
      });

      test('handles null arguments correctly', () {
        final json = {
          'rt': {'id': 'test'},
          // args is null/absent
        };

        final node = RouteNodeSerializationTools.fromJson(json);
        expect(node.arguments, isEmpty);
        expect(node.route.id, equals('test'));
      });

      test('handles empty arguments map correctly', () {
        final json = {
          'rt': {'id': 'test'},
          'args': <String, String>{},
        };

        final node = RouteNodeSerializationTools.fromJson(json);
        expect(node.arguments, isEmpty);
        expect(node.route.id, equals('test'));
      });
    });

    group('fromUri', () {
      test('deserialized as expected', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'home'),
          arguments: const {
            'user': 'watermelon=good',
          },
          children: [
            RouteNode.fromRoute(
              route: const YxRoute(id: 'level1-1'),
              arguments: const {
                'arg1': 'value1',
                'arg2': 'value2',
              },
            ),
          ],
        );

        final uri = UriFragmentBasedSerializer.toUri(node);
        const rawUri =
            r'''#('cnQ':('aWQ':'aG9tZQ'),'YXJncw':('dXNlcg':'d2F0ZXJtZWxvbj1nb29k'),'Yw':&('cnQ':('aWQ':'bGV2ZWwxLTE'),'YXJncw':('YXJnMQ':'dmFsdWUx','YXJnMg':'dmFsdWUy'))$)''';
        final decoded = UriFragmentBasedSerializer.fromUri(uri);

        expect(decoded, equals(node));
        expect(uri.toString(), equals(rawUri));
      });

      test('reserved symbols are decoded correctly', () {
        final node = RouteNode.fromRoute(
          route: const YxRoute(id: 'a[]{}"b'),
          arguments: const {
            'key[]{}"': 'value[]{}"',
          },
        );

        final uri = UriFragmentBasedSerializer.toUri(node);
        final decoded = UriFragmentBasedSerializer.fromUri(uri);
        const rawUri =
            r'''#('cnQ':('aWQ':'YVtde30iYg'),'YXJncw':('a2V5W117fSI':'dmFsdWVbXXt9Ig'))''';

        expect(decoded, equals(node));
        expect(uri.toString(), equals(rawUri));
      });

      test('handles empty fragment gracefully', () {
        final uri = Uri(fragment: '');
        decodeFunction() => UriFragmentBasedSerializer.fromUri(uri);
        expect(decodeFunction, throwsFormatException);
      });
    });
  });
}
